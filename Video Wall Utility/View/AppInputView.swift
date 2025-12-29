import SwiftUI

struct AppInputView: View {
    @Binding var inputState: AppInputState
    
    var body: some View {
        formGroup("Input", icon: "rectangle.connected.to.line.below") {
            formEnumPicker(selection: $inputState.source, label: "Source")
            formEnumPicker(selection: $inputState.edidUsbc, label: "EDID USB-C")
            formEnumPicker(selection: $inputState.edidHdmi, label: "EDID HDMI")
        }
    }
}

#Preview {
    AppInputView(inputState: .constant(AppInputState()))
}
