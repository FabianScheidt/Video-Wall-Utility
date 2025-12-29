internal import Combine
import Foundation

class StateControllerMock: AppState, AbstractStateController {
    private var cancellables = Set<AnyCancellable>()
    
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
        
        $output.changes(of: \.mode)
            .sink { old, new in print("Mode changed: \(old) → \(new)") }
            .store(in: &cancellables)
        
        $output.changes(of: \.resolution)
            .sink { old, new in print("Resolution changed: \(old) → \(new)") }
            .store(in: &cancellables)
        
        $output.changes(of: \.bezelHorizontal)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { old, new in print("Bezel H changed: \(old) → \(new)") }
            .store(in: &cancellables)
        
        $output.changes(of: \.bezelVertical)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { old, new in print("Bezel V changed: \(old) → \(new)") }
            .store(in: &cancellables)
        
        $output.changes(of: \.rotateDisplay1)
            .sink { old, new in print("Rotate Display 1 changed: \(old) → \(new)") }
            .store(in: &cancellables)
        
        $output.changes(of: \.rotateDisplay2)
            .sink { old, new in print("Rotate Display 2 changed: \(old) → \(new)") }
            .store(in: &cancellables)
        
        $output.changes(of: \.rotateDisplay3)
            .sink { old, new in print("Rotate Display 3 changed: \(old) → \(new)") }
            .store(in: &cancellables)
        
        $output.changes(of: \.rotateDisplay4)
            .sink { old, new in print("Rotate Display 4 changed: \(old) → \(new)") }
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
        try? await Task.sleep(nanoseconds: 200_000_000)
        self.output.mode = .mode2x2
        try? await Task.sleep(nanoseconds: 200_000_000)
        self.output.resolution = .resolution1920x1080p60
        try? await Task.sleep(nanoseconds: 200_000_000)
        self.output.bezelHorizontal = 0
        try? await Task.sleep(nanoseconds: 200_000_000)
        self.output.bezelVertical = 2
        try? await Task.sleep(nanoseconds: 200_000_000)
        self.output.rotateDisplay1 = false
        try? await Task.sleep(nanoseconds: 200_000_000)
        self.output.rotateDisplay2 = false
        try? await Task.sleep(nanoseconds: 200_000_000)
        self.output.rotateDisplay3 = true
        try? await Task.sleep(nanoseconds: 200_000_000)
        self.output.rotateDisplay4 = false
    }
    
    func disconnect() async {
        self.device.status = .disconnected
        self.device.firmwareVersion = nil
        self.input = AppInputState()
        self.system = AppSystemState()
        self.output = AppOutputState()
    }
    
    func refresh() async {
        await disconnect()
        await connect()
    }
    
    func reboot() async {
        print("Reboot!")
        await refresh()
    }
    
    func factoryReset() async {
        print("Factory Reset!")
        await refresh()
    }
}
