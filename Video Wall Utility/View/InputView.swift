import SwiftUI

struct InputView: View {
    @Binding var inputState: AppInputState
    
    var body: some View {
        formGroup("Input", icon: "rectangle.connected.to.line.below") {
            Picker(selection: $inputState.source, label: formLabel("Source")) {
                if inputState.source == nil {
                    Text("").tag(nil as InputSource?)
                }
                Text("USB-C").tag(InputSource.usbc)
                Text("HDMI").tag(InputSource.hdmi)
            }.disabled(inputState.source == nil)
            edidPicker(selection: $inputState.edidUsbc, label: "EDID USB-C")
            edidPicker(selection: $inputState.edidHdmi, label: "EDID HDMI")
        }
    }
    
    @ViewBuilder
    private func edidPicker(selection: Binding<InputEdid?>, label: String) -> some View {
        Picker(selection: selection, label: formLabel(label)) {
            if selection.wrappedValue == nil {
                Text("").tag(nil as InputEdid?)
            }
            Text("4k60, 2.0ch").tag(InputEdid.video4k60audio20)
            Text("4k60, 5.1ch").tag(InputEdid.video4k60audio51)
            Text("4k30, 2.0ch").tag(InputEdid.video4k30audio20)
            Text("4k30, 5.1ch").tag(InputEdid.video4k30audio51)
            Text("1080p, 2.0ch").tag(InputEdid.video1080audio20)
            Text("1080p, 5.1ch").tag(InputEdid.video1080audio51)
        }.disabled(selection.wrappedValue == nil)
    }

}

#Preview {
    InputView(inputState: .constant(AppInputState()))
}
