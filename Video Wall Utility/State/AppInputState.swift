struct AppInputState {
    var source: InputSource? = nil
    var edidUsbc: InputEdid? = nil
    var edidHdmi: InputEdid? = nil
    
    init(source: InputSource? = nil, edidUsbc: InputEdid? = nil, edidHdmi: InputEdid? = nil) {
        self.source = source
        self.edidUsbc = edidUsbc
        self.edidHdmi = edidHdmi
    }
}

enum InputSource: Int, Codable, CaseIterable, CustomStringConvertible {
    case hdmi = 1
    case usbc = 2
    
    var description: String {
        switch self {
        case .hdmi: return "HDMI"
        case .usbc: return "USB-C"
        }
    }
    
    static func fromDeviceString(_ deviceString: String) -> InputSource? {
        switch deviceString.lowercased() {
        case "hdmi": return .hdmi
        case "usbc", "usb-c": return .usbc
        default: return nil
        }
    }
}

enum InputEdid: Int, Codable, CaseIterable, CustomStringConvertible {
    case video4k60audio20 = 1
    case video4k60audio51 = 2
    case video4k30audio20 = 3
    case video4k30audio51 = 4
    case video1080audio20 = 5
    case video1080audio51 = 6
    
    var description: String {
        switch self {
            case .video4k60audio20: return "4k60, 2.0ch"
            case .video4k60audio51: return "4k60, 5.1ch"
            case .video4k30audio20: return "4k30, 2.0ch"
            case .video4k30audio51: return "4k30, 5.1ch"
            case .video1080audio20: return "1080p, 2.0ch"
            case .video1080audio51: return "1080p, 5.1ch"
        }
    }
    
    static func fromDeviceString(_ deviceString: String) -> InputEdid? {
        switch deviceString.lowercased() {
        case "4k60,2.0ch": return .video4k60audio20
        case "4k60,5.1ch": return .video4k60audio51
        case "4k30,2.0ch": return .video4k30audio20
        case "4k30,5.1ch": return .video4k30audio51
        case "1080p,2.0ch": return .video1080audio20
        case "1080p,5.1ch": return .video1080audio51
        default: return nil
        }
    }
}
