import SwiftUI

public struct hPill: View {
    public init(
        text: String,
        color: PillColor,
        colorLevel: PillColor.PillColorLevel? = .one,
        withBorder: Bool = true
    ) {
        self.text = text
        self.color = color
        self.colorLevel = colorLevel ?? .one
        self.withBorder = withBorder
    }

    public let text: String
    private let color: PillColor
    private let colorLevel: PillColor.PillColorLevel
    let withBorder: Bool
    @Environment(\.hFieldSize) var fieldSize
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.hPillAttributes) var attributes

    public var body: some View {
        HStack(spacing: .padding6) {
            hText(text, style: getFontStyle)
                .fixedSize(horizontal: sizeCategory <= .large, vertical: false)
                .foregroundColor(color.pillTextColor(level: colorLevel))

            if attributes.contains(.withChevron) {
                hCoreUIAssets.chevronDown.view
                    .foregroundColor(hFillColor.Translucent.tertiary)
            }
        }
        .modifier(PillModifier(color: color, colorLevel: colorLevel, withBorder: withBorder))
        .accessibilityElement(children: .combine)
    }

    private var getFontStyle: HFontTextStyle {
        switch fieldSize {
        case .large, .capsuleShape:
            return .body1
        default:
            return .label
        }
    }
}

extension View {
    public func hPillStyle(
        color: PillColor,
        colorLevel: PillColor.PillColorLevel = .one,
        withBorder: Bool = false
    ) -> some View {
        self.modifier(PillModifier(color: color, colorLevel: colorLevel, withBorder: withBorder))
    }
}

fileprivate struct PillModifier: ViewModifier {
    let color: PillColor
    let colorLevel: PillColor.PillColorLevel
    let withBorder: Bool
    @Environment(\.hFieldSize) var fieldSize
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, getHorizontalPadding)
            .padding(.top, getTopPadding)
            .padding(.bottom, getBottomPadding)
            .background(
                RoundedRectangle(cornerRadius: getCornerRadius)
                    .fill(color.pillBackgroundColor(level: colorLevel))
            )
            .overlay {
                if withBorder {
                    RoundedRectangle(cornerRadius: getCornerRadius)
                        .stroke(hBorderColor.primary, lineWidth: 1)
                }
            }
            .accessibilityElement(children: .combine)
    }

    private var getHorizontalPadding: CGFloat {
        switch fieldSize {
        case .small:
            return .padding6
        case .medium:
            return .padding10
        case .large, .extraLarge:
            return .padding12
        case .capsuleShape:
            return .padding14
        }
    }

    private var getTopPadding: CGFloat {
        switch fieldSize {
        case .small:
            return 3
        case .medium:
            return 6.5
        case .large, .capsuleShape, .extraLarge:
            return 7
        }
    }

    private var getBottomPadding: CGFloat {
        switch fieldSize {
        case .small:
            return 3
        case .medium:
            return 7.5
        case .large, .capsuleShape, .extraLarge:
            return 9
        }
    }

    private var getCornerRadius: CGFloat {
        switch fieldSize {
        case .small:
            return .cornerRadiusXS
        case .medium:
            return .cornerRadiusS
        case .large:
            return .cornerRadiusM
        case .extraLarge:
            return .cornerRadiusXL
        case .capsuleShape:
            return 100
        }
    }
}

extension View {
    public func hWrapInPill(
        color: PillColor,
        colorLevel: PillColor.PillColorLevel = .one,
        withBorder: Bool = false
    ) -> some View {
        modifier(PillWrapperModifier(color: color, colorLevel: colorLevel, withBorder: false))
    }
}
fileprivate struct PillWrapperModifier: ViewModifier {
    let color: PillColor
    let colorLevel: PillColor.PillColorLevel
    let withBorder: Bool
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: .infinity)
                    .fill(color.pillBackgroundColor(level: colorLevel))
            )
            .overlay {
                if withBorder {
                    RoundedRectangle(cornerRadius: .infinity)
                        .stroke(hBorderColor.primary, lineWidth: 1)
                }
            }
            .accessibilityElement(children: .combine)
    }
}

@MainActor
public enum PillColor {
    case green
    case yellow
    case blue
    case teal
    case purple
    case pink
    case amber
    case red
    case grey
    case clear

    @hColorBuilder
    func pillBackgroundColor(level: PillColor.PillColorLevel) -> some hColor {
        switch self {
        case .blue:
            switch level {
            case .one:
                hHighlightColor.Blue.fillOne
            case .two:
                hHighlightColor.Blue.fillTwo
            case .three:
                hHighlightColor.Blue.fillThree
            }
        case .teal:
            switch level {
            case .one:
                hHighlightColor.Teal.fillOne
            case .two:
                hHighlightColor.Teal.fillTwo
            case .three:
                hHighlightColor.Teal.fillThree
            }
        case .green:
            switch level {
            case .one:
                hHighlightColor.Green.fillOne
            case .two:
                hHighlightColor.Green.fillTwo
            case .three:
                hHighlightColor.Green.fillThree
            }
        case .yellow:
            switch level {
            case .one:
                hHighlightColor.Yellow.fillOne
            case .two:
                hHighlightColor.Yellow.fillTwo
            case .three:
                hHighlightColor.Yellow.fillThree
            }
        case .purple:
            switch level {
            case .one:
                hHighlightColor.Purple.fillOne
            case .two:
                hHighlightColor.Purple.fillTwo
            case .three:
                hHighlightColor.Purple.fillThree
            }
        case .pink:
            switch level {
            case .one:
                hHighlightColor.Pink.fillOne
            case .two:
                hHighlightColor.Pink.fillTwo
            case .three:
                hHighlightColor.Pink.fillThree
            }
        case .amber:
            switch level {
            case .one:
                hHighlightColor.Amber.fillOne
            case .two:
                hHighlightColor.Amber.fillTwo
            case .three:
                hHighlightColor.Amber.fillThree
            }
        case .red:
            switch level {
            case .one:
                hHighlightColor.Red.fillOne
            case .two:
                hHighlightColor.Red.fillTwo
            case .three:
                hHighlightColor.Red.fillThree
            }
        case .grey:
            switch level {
            case .one:
                hSurfaceColor.Translucent.primary
            case .two:
                hSurfaceColor.Translucent.secondary
            case .three:
                hBackgroundColor.negative
            }
        case .clear:
            hBackgroundColor.clear
        }
    }

    @hColorBuilder
    func pillTextColor(level: PillColor.PillColorLevel) -> some hColor {
        if self == .grey || self == .clear {
            switch level {
            case .one, .two: hTextColor.Opaque.primary
            case .three: hTextColor.Opaque.negative
            }
        } else {
            hTextColor.Opaque.black
        }
    }

    public enum PillColorLevel {
        case one
        case two
        case three
    }
}

public enum hPillAttrubutes {
    case withChevron
}

private struct EnvironmentHPillAttributes: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: [hPillAttrubutes] = []
}

extension EnvironmentValues {
    public var hPillAttributes: [hPillAttrubutes] {
        get { self[EnvironmentHPillAttributes.self] }
        set { self[EnvironmentHPillAttributes.self] = newValue }
    }
}

extension View {
    public func hPillAttributes(attributes: [hPillAttrubutes]) -> some View {
        environment(\.hPillAttributes, attributes)
    }
}

#Preview {
    VStack {
        HStack {
            hPill(
                text: "Highlight label",
                color: .blue
            )
            .hFieldSize(.large)

            hPill(
                text: "Highlight label",
                color: .blue
            )
            .hFieldSize(.medium)

            hPill(
                text: "Highlight label",
                color: .blue
            )
            .hFieldSize(.small)
        }
        HStack {
            hPill(
                text: "Highlight label",
                color: .blue,
                colorLevel: .two
            )
            .hFieldSize(.large)

            hPill(
                text: "Highlight label",
                color: .blue,
                colorLevel: .two
            )
            .hFieldSize(.medium)

            hPill(
                text: "Highlight label",
                color: .blue,
                colorLevel: .two
            )
            .hFieldSize(.small)
        }
        HStack {
            hPill(
                text: "Highlight label",
                color: .blue,
                colorLevel: .three
            )
            .hFieldSize(.large)

            hPill(
                text: "Highlight label",
                color: .blue,
                colorLevel: .three
            )
            .hFieldSize(.medium)

            hPill(
                text: "Highlight label",
                color: .blue,
                colorLevel: .three
            )
            .hFieldSize(.small)
        }
        HStack {
            hPill(
                text: "Highlight label",
                color: .pink,
                colorLevel: .one
            )
            .hFieldSize(.large)

            hPill(
                text: "Highlight label",
                color: .pink,
                colorLevel: .two
            )
            .hFieldSize(.medium)

            hPill(
                text: "Highlight label",
                color: .pink,
                colorLevel: .three
            )
            .hFieldSize(.small)
        }
        HStack {
            hPill(
                text: "Highlight label",
                color: .grey
            )

            hPill(
                text: "Highlight label",
                color: .grey
            )
            .hFieldSize(.medium)

            hPill(
                text: "Highlight label",
                color: .grey
            )
            .hFieldSize(.small)
        }
        HStack {
            hPill(
                text: "Highlight label",
                color: .grey,
                colorLevel: .two
            )

            hPill(
                text: "Highlight label",
                color: .grey,
                colorLevel: .two
            )
            .hFieldSize(.medium)

            hPill(
                text: "Highlight label",
                color: .grey,
                colorLevel: .two
            )
            .hFieldSize(.small)
        }
    }
}
