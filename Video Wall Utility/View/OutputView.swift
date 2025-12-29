import SwiftUI

struct OutputView: View {
    var body: some View {
        formGroup("Output", icon: "display.2") {
            Picker(selection: .constant(1), label: formLabel("Mode")) {
                Text("1x1").tag(1)
                Text("2x1").tag(2)
                Text("3x1").tag(3)
                Text("4x1").tag(4)
                Text("1x2").tag(5)
                Text("1x3").tag(6)
                Text("1x4").tag(7)
                Text("2x2").tag(8)
            }
            Picker(selection: .constant(2), label: formLabel("Resolution")) {
                Text("1280x720p60").tag(1)
                Text("1920x1080p60").tag(2)
                Text("3840x2160p30").tag(3)
                Text("1024x768@60").tag(4)
            }
            Slider(value: .constant(0.0), in: 0...10, step: 1) {
                formLabel("Bezel H")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("10")
            }.frame(maxWidth: 250)
            Slider(value: .constant(0.0), in: 0...10, step: 1) {
                formLabel("Bezel V")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("10")
            }.frame(maxWidth: 250)
            
            Divider().padding(.vertical, 18)
            
            VStack(alignment: .leading) {
                Text("Rotate 180°")
                Grid() {
                    GridRow() {
                        Toggle(isOn: .constant(false)) {
                            Text("Display 1")
                        }
                        Toggle(isOn: .constant(false)) {
                            Text("Display 2")
                        }
                    }
                    GridRow() {
                        Toggle(isOn: .constant(false)) {
                            Text("Display 3")
                        }
                        Toggle(isOn: .constant(false)) {
                            Text("Display 4")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    OutputView()
}
