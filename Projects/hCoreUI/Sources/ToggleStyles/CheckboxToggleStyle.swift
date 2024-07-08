import Foundation
import SwiftUI

public struct CheckboxToggleStyle: ToggleStyle {
    let withSubtitle: Bool
    @Environment(\.hFieldSize) var fieldSize

    public func makeBody(configuration: Configuration) -> some View {
        hSection {
            hRow {
                configuration.label
            }
            .verticalPadding(0)
            .hWithoutHorizontalPadding
            .padding(.top, getTopPadding)
            .padding(.bottom, getBottomPadding)
            .padding(.horizontal, getHorizontalPadding)
        }
        .sectionContainerStyle(.opaque)
    }

    private var getTopPadding: CGFloat {
        if withSubtitle {
            return .padding12
        } else {
            if fieldSize == .small {
                return 15
            }
            return .padding16
        }
    }

    private var getBottomPadding: CGFloat {
        if withSubtitle {
            return 14
        } else {
            if fieldSize == .small {
                return 17
            }
            return 18
        }
    }

    private var getHorizontalPadding: CGFloat {
        if withSubtitle {
            return .padding16
        } else {
            if fieldSize == .small {
                return 14
            }
            return .padding16
        }
    }
}

public struct CheckboxToggleView: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    @Environment(\.hFieldSize) var fieldSize

    public init(
        title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }

    public var body: some View {
        Toggle(isOn: $isOn.animation(.default)) {
            mainContent
        }
        .toggleStyle(CheckboxToggleStyle(withSubtitle: subtitle != nil))
    }

    @ViewBuilder
    public var mainContent: some View {
        VStack(alignment: .leading, spacing: .padding8) {
            HStack(alignment: .center, spacing: 0) {
                hText(title, style: getTitleStyle(subtitle: subtitle))
                    .foregroundColor(hTextColor.Opaque.primary)
                    .fixedSize()

                Spacer()
                checkbox
            }

            if let subtitle {
                hText(subtitle, style: .standardSmall)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
    }

    private var checkbox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9)
                .fill(backgroundColor(isOn: isOn))
                .onTapGesture {
                    withAnimation(.spring()) {
                        isOn.toggle()
                    }
                }
            Circle()
                .fill(hTextColor.Opaque.white)
                .padding(1)
                .offset(x: isOn ? 5 : -5)
        }
        .frame(width: 28, height: 18)
    }

    private func getTitleStyle(subtitle: String?) -> HFontTextStyle {
        if fieldSize == .large {
            if subtitle != nil {
                return .body1
            }
            return .heading2
        } else if subtitle != nil {
            return .standardSmall
        }
        return .body1
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
    @State static var isOn: Bool = true
    static var previews: some View {
        VStack {
            CheckboxToggleView(
                title: "Large label",
                subtitle: "This is the description area where you can expand upon this option.",
                isOn: $isOn
            )
            .hFieldSize(.large)

            CheckboxToggleView(
                title: "Small label",
                subtitle: "This is the description area where you can expand upon this option.",
                isOn: $isOn
            )
            .hFieldSize(.small)

            CheckboxToggleView(
                title: "Large label",
                isOn: $isOn
            )
            .hFieldSize(.large)

            CheckboxToggleView(
                title: "Medium label",
                isOn: $isOn
            )
            .hFieldSize(.medium)

            CheckboxToggleView(
                title: "Small label",
                isOn: $isOn
            )
            .hFieldSize(.small)
        }
    }
}
