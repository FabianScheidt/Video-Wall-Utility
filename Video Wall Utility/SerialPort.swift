import IOKit.serial
import Foundation
import OSLog
internal import Combine


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
    private let encoding: String.Encoding
    private let lineDelimiter: Data
    private let logger: Logger
    
    private var readSource: DispatchSourceRead?
    
    private let dataSubject = PassthroughSubject<Data, Never>()
    public let data: AnyPublisher<Data, Never>
    public let lines: AnyPublisher<String, Never>
    
    init(
        encoding: String.Encoding = .gb18030,
        lineDelimiter: Data = Data([0x0D, 0x0A]), // \r\n
        logger: Logger = Logger()
    ) {
        self.encoding = encoding
        self.lineDelimiter = lineDelimiter
        self.logger = logger
        self.data = self.dataSubject.eraseToAnyPublisher()
        self.lines = self.data
            .scan((remainder: Data(), lines: [String]())) { state, newData in
                var buffer = state.remainder
                buffer.append(newData)
                
                var lines: [String] = []
                while let range = buffer.range(of: lineDelimiter) {
                    let lineData = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
                    buffer.removeSubrange(buffer.startIndex..<range.upperBound)

                    if let line = String(data: lineData, encoding: encoding) {
                        logger.info("Received line from serial device: \(line)")
                        lines.append(line)
                    } else {
                        logger.info("Received line that could not be decoded.")
                    }
                }

                return (remainder: buffer, lines: lines)
            }
            .flatMap { state in
                Publishers.Sequence(sequence: state.lines)
            }
            .eraseToAnyPublisher()
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
        
        if fd != -1 {
            Darwin.close(fd)
        }
        fd = -1
    }
    
    func sendLine(_ string: String) -> Bool {
        logger.info("Sending line to serial device: \(string)")
        guard let data = string.data(using: self.encoding) else {
            return false
        }
        return send(data + self.lineDelimiter)
    }
    
    func send(_ data: Data) -> Bool {
        guard fd != -1 else { return false }
        
        let written = data.withUnsafeBytes { ptr in
            write(fd, ptr.baseAddress, data.count)
        }
        return written == data.count
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
                DispatchQueue.main.async {
                    self.dataSubject.send(Data(temp[0..<n]))
                }
            }
        }

        src.resume()
    }
}
