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

enum InputSource: CaseIterable, WithId, WithLabel {
    case hdmi
    case usbc
    
    var id: Int {
        switch self {
        case .hdmi: return 1
        case .usbc: return 2
        }
    }
    
    var label: String {
        switch self {
        case .hdmi: return "HDMI"
        case .usbc: return "USB-C"
        }
    }
}

enum InputEdid: CaseIterable, WithId, WithLabel {
    case video4k60audio20
    case video4k60audio51
    case video4k30audio20
    case video4k30audio51
    case video1080audio20
    case video1080audio51
    
    var id: Int {
        switch self {
            case .video4k60audio20: return 1
            case .video4k60audio51: return 2
            case .video4k30audio20: return 3
            case .video4k30audio51: return 4
            case .video1080audio20: return 5
            case .video1080audio51: return 6
        }
    }
    
    var label: String {
        switch self {
            case .video4k60audio20: return "4k60, 2.0ch"
            case .video4k60audio51: return "4k60, 5.1ch"
            case .video4k30audio20: return "4k30, 2.0ch"
            case .video4k30audio51: return "4k30, 5.1ch"
            case .video1080audio20: return "1080p, 2.0ch"
            case .video1080audio51: return "1080p, 5.1ch"
        }
    }
}
