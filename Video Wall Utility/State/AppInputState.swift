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

enum InputSource {
    case usbc
    case hdmi
}

enum InputEdid {
    case video4k60audio20
    case video4k60audio51
    case video4k30audio20
    case video4k30audio51
    case video1080audio20
    case video1080audio51
}
