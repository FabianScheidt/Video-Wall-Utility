internal import Combine


class AppState: ObservableObject {
    @Published var device: AppDeviceState = AppDeviceState()
    @Published var input: AppInputState = AppInputState()
    @Published var system: AppSystemState = AppSystemState()
}
