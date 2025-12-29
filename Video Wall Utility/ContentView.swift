import SwiftUI
internal import Combine


struct ContentView<StateControllerImpl: AbstractStateController>: View {
    @StateObject var state: StateControllerImpl
    
    var body: some View {
        VStack(spacing: 0) {
            AppDeviceView(
                deviceState: $state.device,
                connect: { Task { await state.connect() } },
                disconnect: { Task { await state.disconnect() } },
                refresh: { Task { await state.refresh() } }
            ).padding().background(.thinMaterial)
            
            Divider()
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 16) {
                    AppInputView(inputState: $state.input)
                    AppSystemView(
                        systemState: $state.system,
                        reboot: { Task { await state.reboot() } },
                        factoryReset: { Task { await state.factoryReset() } },
                    )
                }
                VStack {
                    AppOutputView(outputState: $state.output)
                }
            }.frame(maxHeight: .infinity).padding(8)
        }.ignoresSafeArea(.container, edges: .top).task() {
            await state.fetchDevices()
        }
    }
}

#Preview {
    ContentView(state: StateControllerMock())
}
