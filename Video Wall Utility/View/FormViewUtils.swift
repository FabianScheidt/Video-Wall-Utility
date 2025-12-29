import SwiftUI

@ViewBuilder
func formGroup<Content: View>(
    _ title: String,
    icon: String,
    maxWidth: CGFloat? = .infinity,
    @ViewBuilder content: () -> Content
) -> some View {
    GroupBox(label: Label(title, systemImage: icon).font(.headline)) {
        VStack(alignment: .leading, content: content).frame(maxWidth: maxWidth).padding(8)
    }
}

@ViewBuilder
func formLabel(_ label: String) -> some View {
    Text(label).frame(minWidth: 80, alignment: .trailing)
}

@ViewBuilder
func formEnumPicker<EnumType: Hashable & CaseIterable & WithLabel>(selection: Binding<EnumType?>, label: String) -> some View {
    Picker(selection: selection, label: formLabel(label)) {
        if selection.wrappedValue == nil {
            Text("").tag(nil as EnumType?)
        }
        ForEach(Array(EnumType.allCases), id: \.self) { value in
            Text(value.label).tag(value)
        }
    }.disabled(selection.wrappedValue == nil)
}

@ViewBuilder
func formToggle(isOn: Binding<Bool?>, label: String) -> some View {
    Toggle(isOn: Binding(
        get: { isOn.wrappedValue ?? false },
        set: { isOn.wrappedValue = $0 }
    )) {
        Text(label)
    }.disabled(isOn.wrappedValue == nil)
}
