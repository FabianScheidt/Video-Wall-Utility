import SwiftUI
internal import Combine


class MockupViewState: AppState {
    private var cancellables = Set<AnyCancellable>()
    
    // Todo: Replace with actual implementation
    override init() {
        super.init()
        $input.changes(of: \.source)
            .sink { old, new in print("Source changed: \(old) → \(new)") }
            .store(in: &cancellables)

        $input.changes(of: \.edidUsbc)
            .sink { old, new in print("EDID USB-C changed: \(old) → \(new)") }
            .store(in: &cancellables)

        $input.changes(of: \.edidHdmi)
            .sink { old, new in print("EDID HDMI changed: \(old) → \(new)") }
            .store(in: &cancellables)
        
        $system.changes(of: \.power)
            .sink { old, new in print("Power changed: \(old) → \(new)") }
            .store(in: &cancellables)
    }
    
    func fetchDevices() {
        self.device.devices = [
            "/dev/tty.usbserial-FTELA902",
            "/dev/tty.debug-console",
        ]
        self.device.device = device.devices[0]
    }
    
    func connect() async {
        self.device.status = .loading
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        self.device.status = .connected
        try? await Task.sleep(nanoseconds: 200_000_000)
        self.device.firmwareVersion = "1.0.4"
        try? await Task.sleep(nanoseconds: 200_000_000)
        self.input.source = .usbc
        try? await Task.sleep(nanoseconds: 200_000_000)
        self.input.edidUsbc = .video4k60audio20
        try? await Task.sleep(nanoseconds: 200_000_000)
        self.input.edidHdmi = .video4k60audio20
        try? await Task.sleep(nanoseconds: 200_000_000)
        self.system.power = true
    }
    
    func disconnect() async {
        self.device.status = .disconnected
        self.device.firmwareVersion = nil
        self.input = AppInputState()
        self.system = AppSystemState()
    }
    
    func refresh() async {
        await disconnect()
        await connect()
    }
    
    func reboot() async {
        
    }
    
    func factoryReset() async {
        
    }
}


struct MockupView: View {
    @StateObject private var state = MockupViewState()
    
    var body: some View {
        VStack(spacing: 0) {
            DeviceView(
                deviceState: $state.device,
                connect: { Task { await state.connect() } },
                disconnect: { Task { await state.disconnect() } },
                refresh: { Task { await state.refresh() } }
            ).padding().background(.thinMaterial)
            
            Divider()
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 16) {
                    InputView(inputState: $state.input)
                    SystemView(
                        systemState: $state.system,
                        reboot: { Task { await state.reboot() } },
                        factoryReset: { Task { await state.factoryReset() } },
                    )
                }
                VStack {
                    OutputView()
                }
            }.frame(maxHeight: .infinity).padding(8)
        }.ignoresSafeArea(.container, edges: .top).task() {
            state.fetchDevices()
        }
    }
}

#Preview {
    MockupView()
}
