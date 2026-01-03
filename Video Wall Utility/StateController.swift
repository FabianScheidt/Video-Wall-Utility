internal import Combine
import Foundation
import OSLog

protocol AbstractStateController: AppState {
    func fetchDevices() async -> Void
    func connect() async -> Void
    func disconnect() async -> Void
    func refresh() async -> Void
    func reboot() async -> Void
    func factoryReset() async -> Void
}

class StateController: AppState, AbstractStateController {
    private let INIT_FINISHED_REGEX = /^initialization finished!$/
    private let INVALID_ADJUSTMENT_REGEX = /^note: adjustment is not allowed in this mode$/
    private let FIRMWARE_VERSION_REGEX = /^\s*mcu fw version\s*:\s*v?(.+?)\s*$/
    private let INPUT_SOURCE_REGEX = /^output->(hdmi|usbc|usb-c) in$/
    private let INPUT_EDID_HDMI_REGEX = /^hdmi in edid\s*:\s*(.+)$/
    private let INPUT_EDID_USBC_REGEX = /^usb-c in edid\s*:\s*(.+)$/
    private let POWER_REGEX = /^power (on|off)$/
    private let OUTPUT_MODE_REGEX = /^tv wall mode\s*:\s*(.+)$/
    private let OUTPUT_RESOLUTION_REGEX = /^tv wall resolution\s*:\s*(.+)$/
    private let OUTPUT_BEZELH_REGEX = /^tv wall horizontal bezel\s*:\s*([0-9]+)$/
    private let OUTPUT_BEZELV_REGEX = /^tv wall vertical bezel\s*:\s*([0-9]+)$/
    private let OUTPUT_ROTATION_REGEX = /^output\s*([1-4])\s*:\s*(0°|180°) rotation$/
    private let OUTPUT_AUDIO_MUTED_REGEX = /^output audio mute\s*:\s*(on|off)$/
    
    private var connection: SerialPortConnection? = nil
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger()
    
    override init() {
        super.init()
        $input
            .changes(of: \.source)
            .sink { old, new in
                self.logger.info("Source changed: \(old) → \(new)")
                self.connection?.sendLine("s output in source \(new.rawValue)!")
            }
            .store(in: &cancellables)

        $input
            .changes(of: \.edidHdmi)
            .sink { old, new in
                self.logger.info("EDID HDMI changed: \(old) → \(new)")
                self.connection?.sendLine("s input 1 edid \(new.rawValue)!")
            }
            .store(in: &cancellables)
        
        $input
            .changes(of: \.edidUsbc)
            .sink { old, new in
                self.logger.info("EDID USB-C changed: \(old) → \(new)")
                self.connection?.sendLine("s input 2 edid \(new.rawValue)!")
            }
            .store(in: &cancellables)
        
        $system
            .changes(of: \.power)
            .sink { old, new in
                self.logger.info("Power changed: \(old) → \(new)")
                self.connection?.sendLine("s power \(new ? 1 : 0)!")
            }
            .store(in: &cancellables)
        
        $output
            .changes(of: \.mode)
            .sink { old, new in
                self.logger.info("Mode changed: \(old) → \(new)")
                self.connection?.sendLine("s tw mode \(new.rawValue)!")
            }
            .store(in: &cancellables)
        
        $output
            .changes(of: \.resolution)
            .sink { old, new in
                self.logger.info("Resolution changed: \(old) → \(new)")
                self.connection?.sendLine("s tw res \(new.rawValue)!")
            }
            .store(in: &cancellables)
        
        $output
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .changes(of: \.bezelHorizontal)
            .sink { old, new in
                self.logger.info("Bezel H changed: \(old) → \(new)")
                self.connection?.sendLine("s tw h bezel \(new)!")
            }
            .store(in: &cancellables)
        
        $output
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .changes(of: \.bezelVertical)
            .sink { old, new in
                self.logger.info("Bezel V changed: \(old) → \(new)")
                self.connection?.sendLine("s tw v bezel \(new)!")
            }
            .store(in: &cancellables)
        
        $output
            .changes(of: \.rotateDisplay1)
            .sink { old, new in
                self.logger.info("Rotate Display 1 changed: \(old) → \(new)")
                self.connection?.sendLine("s output 1 rotate \(new ? 1 : 0)!")
            }
            .store(in: &cancellables)
        
        $output
            .changes(of: \.rotateDisplay2)
            .sink { old, new in
                self.logger.info("Rotate Display 2 changed: \(old) → \(new)")
                self.connection?.sendLine("s output 2 rotate \(new ? 1 : 0)!")
            }
            .store(in: &cancellables)
        
        $output
            .changes(of: \.rotateDisplay3)
            .sink { old, new in
                self.logger.info("Rotate Display 3 changed: \(old) → \(new)")
                self.connection?.sendLine("s output 3 rotate \(new ? 1 : 0)!")
            }
            .store(in: &cancellables)
        
        $output
            .changes(of: \.rotateDisplay4)
            .sink { old, new in
                self.logger.info("Rotate Display 4 changed: \(old) → \(new)")
                self.connection?.sendLine("s output 4 rotate \(new ? 1 : 0)!")
            }
            .store(in: &cancellables)
    
        $output
            .changes(of: \.audioMuted)
            .sink { old, new in
                self.logger.info("Audio Muted changed: \(old) → \(new)")
                self.connection?.sendLine("s output audio mute \(new ? 1 : 0)!")
            }
            .store(in: &cancellables)
    }
    
    func fetchDevices() async {
        self.device.devices = SerialPortHelper.getAvailableSerialPorts()
        self.device.device = self.device.devices[0]
    }
    
    func connect() async {
        guard let selectedPort = self.device.device else {
            return
        }
        self.device.status = .loading
        
        // Establish connection and request firmware version
        let conn = SerialPortConnection()
        guard
            conn.open(portPath: selectedPort),
            conn.sendLine("r fw version!")
        else {
            logger.error("Failed to establish connection.")
            await self.disconnect()
            return
        }
        
        // Wait for a firmware version response
        let response = try? await conn.readLine(timeout: 1)
        guard response?.wholeMatch(of: FIRMWARE_VERSION_REGEX) != nil else {
            logger.error("Invalid firmware response: \(response ?? "")")
            await self.disconnect()
            return
        }
         
        // We're now connected to a valid device. Start listening
        self.connection = conn
        self.connection?.onLine = self.processLine
        self.device.status = .connected
        
        // Query all parameters
        await self.refresh()
    }
    
    private func processLine(line: String) {
        if (line.wholeMatch(of: INIT_FINISHED_REGEX) != nil) || (line.wholeMatch(of: INVALID_ADJUSTMENT_REGEX) != nil) {
            Task {
                self.resetState()
                // Apparantly, the device needs some more time to respond to our messages
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await self.refresh()
            }
        }
    
        if let match = line.wholeMatch(of: FIRMWARE_VERSION_REGEX) {
            self.device.firmwareVersion = String(match.output.1)
        }
        
        if let match = line.wholeMatch(of: INPUT_SOURCE_REGEX) {
            self.input.source = .fromDeviceString(String(match.output.1))
        }
        
        if let match = line.wholeMatch(of: INPUT_EDID_HDMI_REGEX) {
            self.input.edidHdmi = .fromDeviceString(String(match.output.1))
        }
        
        if let match = line.wholeMatch(of: INPUT_EDID_USBC_REGEX) {
            self.input.edidUsbc = .fromDeviceString(String(match.output.1))
        }
        
        if let match = line.wholeMatch(of: POWER_REGEX) {
            self.system.power = match.output.1 == "on"
        }
        
        if let match = line.wholeMatch(of: OUTPUT_MODE_REGEX) {
            self.output.mode = .fromDeviceString(String(match.output.1))
        }
        
        if let match = line.wholeMatch(of: OUTPUT_RESOLUTION_REGEX) {
            self.output.resolution = .fromDeviceString(String(match.output.1))
        }
        
        if let match = line.wholeMatch(of: OUTPUT_BEZELH_REGEX) {
            self.output.bezelHorizontal = Int(match.output.1)
        }
        
        if let match = line.wholeMatch(of: OUTPUT_BEZELV_REGEX) {
            self.output.bezelVertical = Int(match.output.1)
        }
        
        if let match = line.wholeMatch(of: OUTPUT_ROTATION_REGEX) {
            switch match.output.1 {
            case "1": self.output.rotateDisplay1 = match.output.2 == "180°"
            case "2": self.output.rotateDisplay2 = match.output.2 == "180°"
            case "3": self.output.rotateDisplay3 = match.output.2 == "180°"
            case "4": self.output.rotateDisplay4 = match.output.2 == "180°"
            default: break
            }
        }
        
        if let match = line.wholeMatch(of: OUTPUT_AUDIO_MUTED_REGEX) {
            self.output.audioMuted = match.output.1 == "on"
        }
    }
    
    private func resetState() {
        self.device.firmwareVersion = nil
        self.input = AppInputState()
        self.system = AppSystemState()
        self.output = AppOutputState()
    }
    
    func disconnect() async {
        connection?.close()
        connection = nil
        self.resetState()
        self.device.status = .disconnected
    }
    
    func refresh() async {
        self.resetState()
        
        guard
            let conn = self.connection,
            
            // Device
            conn.sendLine("r fw version!"),
            
            // Input
            conn.sendLine("r output in source!"),
            conn.sendLine("r input 0 edid!"),
            
            // System
            conn.sendLine("r power!"),
                
            // Output
            conn.sendLine("r tw mode!"),
            conn.sendLine("r tw res!"),
            conn.sendLine("r tw h bezel!"),
            conn.sendLine("r tw v bezel!"),
            conn.sendLine("r output 0 rotation!"),
            conn.sendLine("r output audio mute!")
        else {
            logger.error("Failure while sending messages")
            await self.disconnect()
            return
        }
    }
    
    func reboot() async {
        self.resetState()
        self.connection?.sendLine("s reboot!")
    }
    
    func factoryReset() async {
        self.resetState()
        self.connection?.sendLine("s reset!")
    }
}
