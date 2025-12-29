import IOKit.serial
import Foundation
import OSLog


struct SerialPortHelper {
    static func getAvailableSerialPorts() -> [String] {
        var results: [String] = []
        let matchingDict = IOServiceMatching(kIOSerialBSDServiceValue)
        var iterator: io_iterator_t = 0

        let kernResult = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator)
        if kernResult == KERN_SUCCESS {
            var service = IOIteratorNext(iterator)
            while service != 0 {
                if let bsdPathAsCFstring = IORegistryEntryCreateCFProperty(service, kIOCalloutDeviceKey as CFString, kCFAllocatorDefault, 0)?.takeUnretainedValue() as? String {
                    results.append(bsdPathAsCFstring)
                }
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }
            IOObjectRelease(iterator)
        }
        return results
    }
}


class SerialPortConnection {
    private var fd: Int32 = -1
    private let logger = Logger()
    
    private var readSource: DispatchSourceRead?
    private var buffer = Data()
    
    // callback for ongoing streaming
    var onLine: ((String) -> Void)?
    
    // awaiting consumer
    private var pendingContinuation: CheckedContinuation<String, Error>?
    
    enum ReadError: Error {
        case closed
        case timeout
    }

    func open(portPath: String) -> Bool {
        fd = Darwin.open(portPath, O_RDWR | O_NOCTTY | O_NONBLOCK)
        
        guard fd >= 0 else {
            let err = errno
            let message = String(cString: strerror(err))
            logger.error("open() failed for \(portPath): \(message) (\(err))")
            return false
        }
        var options = termios()
        tcgetattr(fd, &options)
        cfsetspeed(&options, speed_t(B115200))
        options.c_cflag |= tcflag_t(CLOCAL | CREAD)
        options.c_cflag &= ~tcflag_t(PARENB)
        options.c_cflag &= ~tcflag_t(CSTOPB)
        options.c_cflag &= ~tcflag_t(CSIZE)
        options.c_cflag |= tcflag_t(CS8)
        options.c_cflag &= ~tcflag_t(CRTSCTS)
        tcsetattr(fd, TCSANOW, &options)

        startReader()
        return true
    }
    
    func close() {
        readSource?.cancel()
        readSource = nil
        buffer.removeAll()
        
        if fd != -1 {
            Darwin.close(fd)
        }
        fd = -1
        
        pendingContinuation?.resume(throwing: ReadError.closed)
        pendingContinuation = nil
    }
    
    func sendLine(_ string: String) -> Bool {
        return send(string + "\r\n")
    }
    
    func send(_ string: String) -> Bool {
        guard fd != -1 else { return false }
        guard let data = string.data(using: .gb18030) else {
            return false
        }
        let written = data.withUnsafeBytes { ptr in
            write(fd, ptr.baseAddress, data.count)
        }
        return written == data.count
    }

    func readLine(timeout: TimeInterval? = nil) async throws -> String? {
        if let data = popNextLineData() {
            return decodeLine(data)
        }

        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<String, Error>) in
            pendingContinuation = cont
            
            if let t = timeout {
                Task {
                    try? await Task.sleep(nanoseconds: UInt64(t * 1_000_000_000))
                    if self.pendingContinuation != nil {
                        self.pendingContinuation?.resume(throwing: ReadError.timeout)
                        self.pendingContinuation = nil
                    }
                }
            }
        }
    }

    private func startReader() {
        guard fd != -1 else { return }

        let src = DispatchSource.makeReadSource(fileDescriptor: fd, queue: .global())
        readSource = src

        src.setEventHandler { [weak self] in
            guard let self else { return }

            var temp = [UInt8](repeating: 0, count: 1024)
            let n = read(self.fd, &temp, temp.count)

            if n > 0 {
                self.buffer.append(contentsOf: temp[0..<n])
                self.processBuffer()
            }
        }

        src.resume()
    }
    
    private func popNextLineData() -> Data? {
        // look for '\n'
        guard let idx = buffer.firstIndex(of: 10 /* \n */) else {
            return nil
        }

        var line = buffer[..<idx]
        buffer.removeSubrange(...idx)

        // strip '\r'
        if line.last == 13 /* \r */ {
            line = line.dropLast()
        }

        return Data(line)
    }

    private func decodeLine(_ data: Data) -> String? {
        if let s = String(data: data, encoding: .gb18030) {
            return s
        }

        logger.error("Received line that could not be decoded.")
        return nil
    }


    private func processBuffer() {
        while let data = popNextLineData() {
            guard let s = decodeLine(data) else { continue }

            if let cont = pendingContinuation {
                pendingContinuation = nil
                cont.resume(returning: s)
            } else {
                DispatchQueue.main.async {
                    self.onLine?(s)
                }
            }
        }
    }
}
