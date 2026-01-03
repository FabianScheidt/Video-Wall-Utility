struct AppOutputState {
    var mode: OutputMode? = nil
    var resolution: OutputResolution? = nil
    var bezelHorizontal: Int? = nil
    var bezelVertical: Int? = nil
    var rotateDisplay1: Bool? = nil
    var rotateDisplay2: Bool? = nil
    var rotateDisplay3: Bool? = nil
    var rotateDisplay4: Bool? = nil
    var audioMuted: Bool? = nil
}

enum OutputMode: Int, Codable, CaseIterable, CustomStringConvertible {
    case mode1x1 = 1
    case mode2x1 = 2
    case mode3x1 = 3
    case mode4x1 = 4
    case mode1x2 = 5
    case mode1x3 = 6
    case mode1x4 = 7
    case mode2x2 = 8
    
    var description: String {
        switch self {
        case .mode1x1: return "1x1"
        case .mode2x1: return "2x1"
        case .mode3x1: return "3x1"
        case .mode4x1: return "4x1"
        case .mode1x2: return "1x2"
        case .mode1x3: return "1x3"
        case .mode1x4: return "1x4"
        case .mode2x2: return "2x2"
        }
    }
    
    static func fromDeviceString(_ deviceString: String) -> OutputMode? {
        switch deviceString.lowercased() {
        case "1x1": return .mode1x1
        case "2x1": return .mode2x1
        case "3x1": return .mode3x1
        case "4x1": return .mode4x1
        case "1x2": return .mode1x2
        case "1x3": return .mode1x3
        case "1x4": return .mode1x4
        case "2x2": return .mode2x2
        default: return nil
        }
    }
}

enum OutputResolution: Int, Codable, CaseIterable, CustomStringConvertible {
    case resolution1280x720p60 = 1
    case resolution1920x1080p60 = 2
    case resolution3840x2160p30 = 3
    case resolution1024x768p60 = 4
    
    var description: String {
        switch self {
        case .resolution1280x720p60: return "1280x720p60 (HD)"
        case .resolution1920x1080p60: return "1920x1080p60 (Full HD)"
        case .resolution3840x2160p30: return "3840x2160p30 (4K UHD)"
        case .resolution1024x768p60: return "1024x768@60 (XGA)"
        }
    }
    
    static func fromDeviceString(_ deviceString: String) -> OutputResolution? {
        switch deviceString.lowercased() {
        case "1280x720p60": return .resolution1280x720p60
        case "1920x1080p60": return .resolution1920x1080p60
        case "3840x2160p30": return .resolution3840x2160p30
        case "1024x768p60": return .resolution1024x768p60
        default: return nil
        }
    }
}
