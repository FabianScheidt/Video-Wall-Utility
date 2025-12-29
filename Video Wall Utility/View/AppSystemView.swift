import SwiftUI

struct AppSystemView: View {
    @Binding var systemState: AppSystemState
    let reboot: () -> Void
    let factoryReset: () -> Void
    
    var body: some View {
        formGroup("System", icon: "gearshape") {
            formToggle(isOn: $systemState.power, label: "Power")
            Divider().padding(.vertical, 6)
            HStack {
                Button("Reboot", action: reboot)
                Spacer()
                Button("Factory Reset", action: factoryReset).tint(.red)
            }
        }.disabled(systemState.power == nil)
    }
}

#Preview {
    AppSystemView(
        systemState: .constant(AppSystemState()),
        reboot: {},
        factoryReset: {}
    )
}
