import SwiftUI

public struct hPill<T: hColor, L: hColor>: View {
    public init(
        text: String,
        color: PillColor?,
        colorLevel: PillColor.PillColorLevel? = .one,
        customizedTextColor: T? = nil,
        customizedBackgroundColor: L? = nil
    ) {
        self.text = text
        self.color = color
        self.colorLevel = colorLevel ?? .one
        self.customizedTextColor = customizedTextColor
        self.customizedBackgroundColor = customizedBackgroundColor
    }

    public let text: String
    private let color: PillColor?
    private let colorLevel: PillColor.PillColorLevel
    private let customizedTextColor: T?
    private let customizedBackgroundColor: L?
    @Environment(\.hFieldSize) var fieldSize

    public var body: some View {
        hText(text, style: fieldSize == .large ? .body1 : .standardSmall)
            .fixedSize()
            .foregroundColor(getTextColor)
            .modifier(
                PillModifier(
                    color: color,
                    customizedBackgroundColor: customizedBackgroundColor,
                    colorLevel: colorLevel
                )
            )
    }

    @hColorBuilder
    private var getTextColor: some hColor {
        if let customizedTextColor {
            customizedTextColor
        } else if let pillTextColor = color?.pillTextColor(level: colorLevel) {
            pillTextColor
        } else {
            hColorBase(.clear)
        }
    }

    struct PillModifier: ViewModifier {
        let color: PillColor?
        let customizedBackgroundColor: L?
        let colorLevel: PillColor.PillColorLevel
        @Environment(\.hFieldSize) var fieldSize

        func body(content: Content) -> some View {
            content
                .padding(.horizontal, getHorizontalPadding)
                .padding(.top, getTopPadding)
                .padding(.bottom, getBottomPadding)
                .background(
                    RoundedRectangle(cornerRadius: getCornerRadius)
                        .fill(getBackgroundColor)
                )
        }

        @hColorBuilder
        private var getBackgroundColor: some hColor {
            if let customizedBackgroundColor {
                customizedBackgroundColor
            } else if let pillBackgroundColor = color?.pillBackgroundColor(level: colorLevel) {
                pillBackgroundColor
            } else {
                hColorBase(.clear)
            }
        }

        private var getHorizontalPadding: CGFloat {
            if fieldSize == .small {
                return .padding6
            } else if fieldSize == .medium {
                return .padding10
            }
            return .padding12
        }

        private var getTopPadding: CGFloat {
            if fieldSize == .small {
                return 3
            } else if fieldSize == .medium {
                return 6.5
            }
            return 7
        }

        private var getBottomPadding: CGFloat {
            if fieldSize == .small {
                return 3
            } else if fieldSize == .medium {
                return 7.5
            }
            return 9
        }

        private var getCornerRadius: CGFloat {
            if fieldSize == .small {
                return .cornerRadiusXS
            } else if fieldSize == .medium {
                return .cornerRadiusS
            }
            return .cornerRadiusM
        }
    }
}

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
                hSurfaceColor.Opaque.primary
            case .two:
                hSurfaceColor.Opaque.secondary
            case .three:
                hBackgroundColor.negative
            }
        }
    }

    @hColorBuilder
    func pillTextColor(level: PillColor.PillColorLevel) -> some hColor {
        switch self {
        case .blue, .teal, .green, .yellow, .amber, .purple, .pink, .red:
            hTextColor.Opaque.black
        case .grey:
            switch level {
            case .one, .two:
                hTextColor.Opaque.primary
            case .three:
                hTextColor.Opaque.negative
            }
        }
    }

    public enum PillColorLevel {
        case one
        case two
        case three
    }
}

struct ClaimStatus_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .blue
                )
                .hFieldSize(.large)

                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .blue
                )
                .hFieldSize(.medium)

                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .blue
                )
                .hFieldSize(.small)
            }
            HStack {
                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .blue,
                    colorLevel: .two
                )
                .hFieldSize(.large)

                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .blue,
                    colorLevel: .two
                )
                .hFieldSize(.medium)

                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .blue,
                    colorLevel: .two
                )
                .hFieldSize(.small)
            }
            HStack {
                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .blue,
                    colorLevel: .three
                )
                .hFieldSize(.large)

                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .blue,
                    colorLevel: .three
                )
                .hFieldSize(.medium)

                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .blue,
                    colorLevel: .three
                )
                .hFieldSize(.small)
            }
            HStack {
                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .pink,
                    colorLevel: .one
                )
                .hFieldSize(.large)

                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .pink,
                    colorLevel: .two
                )
                .hFieldSize(.medium)

                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .pink,
                    colorLevel: .three
                )
                .hFieldSize(.small)
            }
            HStack {
                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .grey
                )

                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .grey
                )
                .hFieldSize(.medium)

                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .grey
                )
                .hFieldSize(.small)
            }
            HStack {
                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .grey,
                    colorLevel: .two
                )

                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .grey,
                    colorLevel: .two
                )
                .hFieldSize(.medium)

                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .grey,
                    colorLevel: .two
                )
                .hFieldSize(.small)
            }
            HStack {
                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .grey,
                    colorLevel: .three
                )

                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .grey,
                    colorLevel: .three
                )
                .hFieldSize(.medium)

                hPill<hColorBase, hColorBase>(
                    text: "Highlight label",
                    color: .grey,
                    colorLevel: .three
                )
                .hFieldSize(.small)
            }

            // customized colors
            hPill(
                text: "Highlight label",
                color: nil,
                customizedTextColor: hTextColor.Opaque.primary,
                customizedBackgroundColor: hHighlightColor.Pink.fillOne
            )
        }
    }
}
