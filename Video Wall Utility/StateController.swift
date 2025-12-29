protocol AbstractStateController: AppState {
    func fetchDevices() async -> Void
    func connect() async -> Void
    func disconnect() async -> Void
    func refresh() async -> Void
    func reboot() async -> Void
    func factoryReset() async -> Void
}

class StateController: AppState, AbstractStateController {
    private var connection: SerialPortConnection? = nil
    
    private let FIRMWARE_VERSION_REGEX = /^mcu fw version:\s*(.+)\s*$/
    private let POWER_REGEX = /^power (on|off)$/
    
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
            print("Failed to establish connection.")
            await self.disconnect()
            return
        }
        
        // Wait for a firmware version response
        let response = try? await conn.readLine(timeout: 1)
        guard response?.wholeMatch(of: FIRMWARE_VERSION_REGEX) != nil else {
            print("Invalid firmware response: " + (response ?? ""))
            await self.disconnect()
            return
        }
         
        // We're now connected to a valid device. Start listening
        self.connection = conn
        self.connection?.onLine = self.processLine
        self.device.status = .connected
        
        // Query all parameters
        guard
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
            print("Failure while sending messages")
            await self.disconnect()
            return
        }
    }
    
    private func processLine(line: String) {
        // Todo: Parse responses and update state accordingly
        print(line)
        
        if let match = line.wholeMatch(of: FIRMWARE_VERSION_REGEX) {
            self.device.firmwareVersion = String(match.output.1)
        }
        
        if let match = line.wholeMatch(of: POWER_REGEX) {
            self.system.power = match.output.1 == "on"
        }
    }
    
    func disconnect() async {
        connection?.close()
        connection = nil
        self.device.status = .disconnected
        self.device.firmwareVersion = nil
    }
    
    func refresh() async {
        await disconnect()
        await connect()
    }
    
    func reboot() async {
        // Todo...
    }
    
    func factoryReset() async {
        // Todo...
    }
}
