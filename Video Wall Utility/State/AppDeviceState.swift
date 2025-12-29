struct AppDeviceState {
    var devices: [String] = []
    var status: ConnectionStatus = .disconnected
    var device: String? = nil
    var firmwareVersion: String? = nil
}

enum ConnectionStatus {
    case disconnected
    case loading
    case connected
}
