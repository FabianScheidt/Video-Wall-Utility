import SwiftUI

struct DeviceView: View {
    @Binding var deviceState: AppDeviceState
    let connect: () -> Void
    let disconnect: () -> Void
    let refresh: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Picker("Device", selection: $deviceState.device) {
                        ForEach(deviceState.devices, id: \.self) { device in
                            Text(device).tag(device)
                        }
                    }.disabled(deviceState.status != .disconnected)
                    
                    if deviceState.status != .connected {
                        Button("Connect", action: connect)
                            .disabled(deviceState.status != .disconnected)
                    } else {
                        Button("Disconnect", action: disconnect)
                    }
                }
                Text(getStatusLabel()).foregroundColor(.secondary)
            }.padding(.top, 24)
            Spacer()
            Button(action: refresh, label: refreshIcon)
                .clipShape(Circle())
                .disabled(deviceState.status != .connected)
        }
    }
    
    private func getStatusLabel() -> String {
        let statusStr = getStatusStr()
        if deviceState.firmwareVersion != nil {
            return statusStr + ", Firmware Version: " + deviceState.firmwareVersion!
        }
        return statusStr
    }
    
    private func getStatusStr() -> String {
        switch deviceState.status {
        case .disconnected:
            return "Disconnected"
        case .loading:
            return "Connecting..."
        case .connected:
            return "Connected"
        }
    }
    
    @ViewBuilder
    private func refreshIcon() -> some View {
        Image(systemName: "arrow.clockwise")
            .font(.system(size: 14, weight: .semibold))
            .labelStyle(.iconOnly)
            .frame(width: 32, height: 32)
    }
}


#Preview {
    DeviceView(
        deviceState: .constant(AppDeviceState()),
        connect: {},
        disconnect: {},
        refresh: {}
    )
}
