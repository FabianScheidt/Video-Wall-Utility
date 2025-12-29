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
    
    func fetchDevices() async {
        self.device.devices = SerialPortHelper.getAvailableSerialPorts()
        self.device.device = self.device.devices[0]
    }
    
    func connect() async {
        guard let selectedPort = self.device.device else {
            return
        }
        self.device.status = .loading
        
        let conn = SerialPortConnection()
        if conn.open(portPath: selectedPort) {
            self.connection = conn
            self.device.status = .connected
            
            // Send r fw version! and read reply
            if conn.send("r fw version!\r\n") {
                if let reply = conn.readLine(timeout: 2.0) {
                    self.device.firmwareVersion = reply
                } else {
                    await self.disconnect()
                }
            } else {
                await self.disconnect()
            }
            
            // Todo: Read other fields...
        } else {
            await self.disconnect()
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
