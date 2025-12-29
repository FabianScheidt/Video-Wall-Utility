protocol AbstractStateController: AppState {
    func fetchDevices() async -> Void
    func connect() async -> Void
    func disconnect() async -> Void
    func refresh() async -> Void
    func reboot() async -> Void
    func factoryReset() async -> Void
}
