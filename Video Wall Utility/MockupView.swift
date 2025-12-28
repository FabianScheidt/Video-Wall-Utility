import SwiftUI

struct MockupView: View {
    @State private var bezelh = 0.0
    @State private var bezelv = 0.0
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Picker("Device", selection: .constant(1)) {
                                Text("/dev/tty.usbserial-FTELA902").tag(1)
                                Text("/dev/tty.debug-console").tag(2)
                            }
                            Button("Disconnect") {}
                        }
                        Text("Connected, Firmware Version: 1.0.4").foregroundColor(.secondary)
                    }.padding(.top, 24)
                    Spacer()
                    Button {} label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .labelStyle(.iconOnly)
                            .frame(width: 32, height: 32)
                    }.clipShape(Circle())
                }.padding()
            }.background(.thinMaterial)
            
            Divider()
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 16) {
                    formGroup("Input", icon: "rectangle.connected.to.line.below") {
                        Picker(selection: .constant(1), label: formLabel("Source")) {
                            Text("USB-C").tag(1)
                            Text("HDMI").tag(2)
                        }
                        Picker(selection: .constant(1), label: formLabel("EDID USB-C")) {
                            Text("4k60, 2.0ch").tag(1)
                            Text("4k60, 5.1ch").tag(2)
                            Text("4k30, 2.0ch").tag(3)
                            Text("4k30, 5.1ch").tag(4)
                            Text("1080p, 2.0ch").tag(5)
                            Text("1080p, 5.1ch").tag(6)
                        }
                        Picker(selection: .constant(1), label: formLabel("EDID HDMI")) {
                            Text("4k60, 2.0ch").tag(1)
                            Text("4k60, 5.1ch").tag(2)
                            Text("4k30, 2.0ch").tag(3)
                            Text("4k30, 5.1ch").tag(4)
                            Text("1080p, 2.0ch").tag(5)
                            Text("1080p, 5.1ch").tag(6)
                        }
                    }
                    formGroup("System", icon: "gearshape") {
                        Toggle(isOn: .constant(true)) {
                            Text("Power")
                        }
                        Divider().padding(.vertical, 6)
                        HStack {
                            Button("Reboot") {}
                            Spacer()
                            Button("Factory Reset") {}.tint(.red)
                        }
                    }
                }
                VStack {
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
                        Slider(value: $bezelh, in: 0...10, step: 1) {
                            formLabel("Bezel H")
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("10")
                        }.frame(maxWidth: 250)
                        Slider(value: $bezelv, in: 0...10, step: 1) {
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
            }.frame(maxHeight: .infinity).padding(8)
        }.ignoresSafeArea(.container, edges: .top)
    }
    
    @ViewBuilder
    private func formGroup<Content: View>(
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
    private func formLabel(_ label: String) -> some View {
        Text(label).frame(minWidth: 80, alignment: .trailing)
    }
}

#Preview {
    MockupView()
}
