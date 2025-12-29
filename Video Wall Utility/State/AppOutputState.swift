struct AppOutputState {
    var mode: OutputMode? = nil
    var resolution: OutputResolution? = nil
    var bezelHorizontal: Int? = nil
    var bezelVertical: Int? = nil
    var rotateDisplay1: Bool? = nil
    var rotateDisplay2: Bool? = nil
    var rotateDisplay3: Bool? = nil
    var rotateDisplay4: Bool? = nil
}

enum OutputMode: CaseIterable, WithId, WithLabel {
    case mode1x1
    case mode2x1
    case mode3x1
    case mode4x1
    case mode1x2
    case mode1x3
    case mode1x4
    case mode2x2
    
    var id: Int {
        switch self {
        case .mode1x1: return 1
        case .mode2x1: return 2
        case .mode3x1: return 3
        case .mode4x1: return 4
        case .mode1x2: return 5
        case .mode1x3: return 6
        case .mode1x4: return 7
        case .mode2x2: return 8
        }
    }
    
    var label: String {
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
}

enum OutputResolution: CaseIterable, WithId, WithLabel {
    case resolution1280x720p60
    case resolution1920x1080p60
    case resolution3840x2160p30
    case resolution1024x768p60
    
    var id: Int {
        switch self {
        case .resolution1280x720p60: return 1
        case .resolution1920x1080p60: return 2
        case .resolution3840x2160p30: return 3
        case .resolution1024x768p60: return 4
        }
    }
    
    var label: String {
        switch self {
        case .resolution1280x720p60: return "1280x720p60"
        case .resolution1920x1080p60: return "1920x1080p60"
        case .resolution3840x2160p30: return "3840x2160p30"
        case .resolution1024x768p60: return "1024x768@60 (XGA)"
        }
    }
}
