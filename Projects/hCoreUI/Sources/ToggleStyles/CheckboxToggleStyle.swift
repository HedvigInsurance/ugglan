import Foundation
import SwiftUI

public struct ChecboxToggleStyle: ToggleStyle {
    let alignment: VerticalAlignment
    let spacing: CGFloat
    @Environment(\.hFieldSize) var fieldSize

    public init(_ alignment: VerticalAlignment, spacing: CGFloat = 0) {
        self.alignment = alignment
        self.spacing = spacing
    }

    public func textLabel(title: String?, subtitle: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: .padding8) {
            if let title {
                hText(title, style: getTitleStyle(subtitle: subtitle))
                    .foregroundColor(hTextColor.Opaque.primary)
            }
            if let subtitle {
                hText(subtitle, style: .standardSmall)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
    }

    private func getTitleStyle(subtitle: String?) -> HFontTextStyle {
        if fieldSize == .large {
            if let subtitle {
                return .body1
            } else {
                return .heading2
            }
        } else if fieldSize == .small || fieldSize == .medium {
            if let subtitle {
                return .standardSmall
            }
            return .body1
        }
        return .body1
    }

    public func makeBody(configuration: Configuration) -> some View {
        hSection {
            hRow {
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
                                .fill(hTextColor.Opaque.white)
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
            .verticalPadding(0)
            .padding(.top, .padding12)
            .padding(.bottom, 14)
        }
        .sectionContainerStyle(.opaque)
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
                ChecboxToggleStyle(.top)
                    .textLabel(
                        title: "Large label",
                        subtitle: "This is the description area where you can expand upon this option."
                    )
                    .hFieldSize(.large)
            }
            .toggleStyle(ChecboxToggleStyle(.top, spacing: 0))
            .hFieldSize(.large)

            Toggle(isOn: $isOn.animation(.default)) {
                ChecboxToggleStyle(.top)
                    .textLabel(
                        title: "Small label",
                        subtitle: "This is the description area where you can expand upon this option."
                    )
            }
            .toggleStyle(ChecboxToggleStyle(.top, spacing: 0))
            .hFieldSize(.small)

            Toggle(isOn: $isOn.animation(.default)) {
                ChecboxToggleStyle(.top).textLabel(title: "Small without subtitle")
                    .hFieldSize(.small)
            }
            .toggleStyle(ChecboxToggleStyle(.top, spacing: 0))
            .hFieldSize(.small)

            Toggle(isOn: $isOn.animation(.default)) {
                ChecboxToggleStyle(.top).textLabel(title: "Medium without subtitle")
            }
            .toggleStyle(ChecboxToggleStyle(.top, spacing: 0))
            .hFieldSize(.medium)

            Toggle(isOn: $isOn.animation(.default)) {
                ChecboxToggleStyle(.top).textLabel(title: "Large without subtitle")
            }
            .toggleStyle(ChecboxToggleStyle(.top, spacing: 0))
            .hFieldSize(.large)
            Spacer()
        }
    }
}

struct ChecboxToggleWithoutSubtitle_Previews: PreviewProvider {
    @State static var isOn: Bool = false
    static var previews: some View {
        VStack {
            Toggle(isOn: $isOn.animation(.default)) {
                ChecboxToggleStyle(.top).textLabel(title: "Label")
            }
            .toggleStyle(ChecboxToggleStyle(.top, spacing: 0))
            Spacer()
        }
    }
}
