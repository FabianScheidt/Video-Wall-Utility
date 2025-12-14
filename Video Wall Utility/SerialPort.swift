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
    private let queue = DispatchQueue(label: "SerialPortQueue")
    private let logger = Logger()
    
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
        return true
    }
    
    func close() {
        if fd != -1 {
            Darwin.close(fd)
        }
        fd = -1
    }
    
    func send(_ string: String) -> Bool {
        guard fd != -1 else { return false }
        let data = [UInt8](string.utf8)
        let written = data.withUnsafeBytes { ptr in
            write(fd, ptr.baseAddress, data.count)
        }
        return written == data.count
    }
    
    func readLine(timeout: TimeInterval) -> String? {
        guard fd != -1 else { return nil }
        var buffer = [UInt8]()
        let deadline = Date().addingTimeInterval(timeout)
        var byte: UInt8 = 0
        while Date() < deadline {
            let result = read(fd, &byte, 1)
            if result == 1 {
                if byte == 0x0A || byte == 0x0D { // LF or CR
                    if !buffer.isEmpty {
                        break
                    }
                } else {
                    buffer.append(byte)
                }
            } else {
                // Sleep for a short interval
                usleep(20000)
            }
        }
        return buffer.isEmpty ? nil : String(bytes: buffer, encoding: .utf8)
    }
}
