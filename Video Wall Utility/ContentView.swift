import SwiftUI
import IOKit.serial
import Foundation
import OSLog

struct ContentView: View {
    @State private var availablePorts: [String] = []
    @State private var selectedPort: String = ""
    @State private var connection: SerialPortConnection? = nil
    @State private var isConnected: Bool = false
    @State private var firmwareVersion: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Picker("Serial Port", selection: $selectedPort) {
                ForEach(availablePorts, id: \.self) { port in
                    Text(port)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 250)
            .disabled(isConnected)
            
            HStack {
                if !isConnected {
                    Button("Connect", action: { connect() }).disabled(selectedPort == "")
                    Text("Not connected").foregroundColor(.secondary)
                } else {
                    Button("Disconnect", action: { disconnect() })
                    Text("Connected").foregroundColor(.green)
                }
            }
            if firmwareVersion != "" {
                Text("Firmware Version: \(firmwareVersion)").foregroundColor(.blue)
            }
        }
        .padding()
        .onAppear {
            let ports = SerialPortHelper.getAvailableSerialPorts()
            self.availablePorts = ports
            self.selectedPort = ports.first ?? ""
        }
    }
    
    func connect() {
        let conn = SerialPortConnection()
        if conn.open(portPath: selectedPort) {
            connection = conn
            isConnected = true
            // Send r fw version! and read reply
            if conn.send("r fw version!\r\n") {
                if let reply = conn.readLine(timeout: 2.0) {
                    firmwareVersion = reply
                } else {
                    disconnect()
                    firmwareVersion = "No reply received."
                }
            } else {
                firmwareVersion = "Failed to send command."
            }
        } else {
            firmwareVersion = "Failed to open port."
        }
    }
    
    func disconnect() {
        connection?.close()
        connection = nil
        isConnected = false
        firmwareVersion = ""
    }
}

#Preview {
    ContentView()
}
