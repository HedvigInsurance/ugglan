import Foundation
import SwiftUI

public struct ChecboxToggleStyle: ToggleStyle {
    let alignment: VerticalAlignment
    let spacing: CGFloat
    public init(_ alignment: VerticalAlignment, spacing: CGFloat = 0) {
        self.alignment = alignment
        self.spacing = spacing
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: alignment, spacing: 0) {
            configuration.label
            Spacer()
            VStack {
                if alignment == .top {
                    Color.clear.frame(height: spacing)
                }
                if alignment == .bottom || alignment == .center {
                    Spacer()
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(backgroundColor(isOn: configuration.isOn))
                        .onTapGesture {
                            withAnimation(.spring()) {
                                configuration.isOn.toggle()
                            }
                        }
                    Circle()
                        .fill(hTextColor.Opaque.negative)
                        .padding(1)
                        .offset(x: configuration.isOn ? 5 : -5)
                }
                .frame(width: 28, height: 18)

                if alignment == .center {
                    Spacer()
                }
                if alignment == .bottom {
                    Color.clear.frame(height: spacing)
                }
            }
            .fixedSize(horizontal: true, vertical: false)
        }
    }

    @hColorBuilder
    func backgroundColor(isOn: Bool) -> some hColor {
        if isOn {
            hSignalColor.Green.element
        } else {
            hFillColor.Opaque.disabled
        }
    }
}

struct ChecboxToggleStyle_Previews: PreviewProvider {
    @State static var isOn: Bool = false
    static var previews: some View {
        VStack {
            Toggle(isOn: $isOn.animation(.default)) {
                VStack(alignment: .leading, spacing: 0) {
                    hText("tasd", style: .heading2)
                    hText("sasdasdasdasd")
                }
            }
            .toggleStyle(ChecboxToggleStyle(.top, spacing: 0))
            Spacer()
        }
    }
}
