import SwiftUI

struct AppOutputView: View {
    @Binding var outputState: AppOutputState
    
    var body: some View {
        formGroup("Output", icon: "display.2") {
            formEnumPicker(selection: $outputState.mode, label: "Mode")
            formEnumPicker(selection: $outputState.resolution, label: "Resolution")
            
            VStack() {
                bezelSlider(value: $outputState.bezelHorizontal, label: "Bezel H")
                bezelSlider(value: $outputState.bezelVertical, label: "Bezel V")
            }.padding(.top, 12)
            
            HStack() {
                formLabel("Rotate 180°")
                
                VStack(alignment: .leading) {
                    Grid() {
                        GridRow() {
                            formToggle(isOn: $outputState.rotateDisplay1, label: "Display 1")
                            formToggle(isOn: $outputState.rotateDisplay2, label: "Display 2")
                        }
                        GridRow() {
                            formToggle(isOn: $outputState.rotateDisplay3, label: "Display 3")
                            formToggle(isOn: $outputState.rotateDisplay4, label: "Display 4")
                        }
                    }
                }
            }.padding(.vertical, 12)
            
            HStack() {
                formLabel("Audio")
                formToggle(isOn: $outputState.audioMuted, label: "Muted")
            }.padding(.bottom, 6)
        }
    }
    
    @ViewBuilder
    func bezelSlider(value: Binding<Int?>, label: String) -> some View {
        Slider(value: Binding(
            get: { value.wrappedValue != nil ? Float(value.wrappedValue!) : 0.0 },
            set: { value.wrappedValue = Int($0) }
        ), in: 0...10, step: 1) {
            formLabel(label)
        } minimumValueLabel: {
            Text("0")
        } maximumValueLabel: {
            Text("10")
        }
        .frame(maxWidth: 250)
        .disabled(value.wrappedValue == nil)
    }

}

#Preview {
    AppOutputView(outputState: .constant(AppOutputState()))
}
