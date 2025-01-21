import SwiftUI

public struct hPill: View {
    public init(
        text: String,
        color: PillColor,
        colorLevel: PillColor.PillColorLevel? = .one
    ) {
        self.text = text
        self.color = color
        self.colorLevel = colorLevel ?? .one
    }

    public let text: String
    private let color: PillColor
    private let colorLevel: PillColor.PillColorLevel
    @Environment(\.hFieldSize) var fieldSize
    @Environment(\.sizeCategory) var sizeCategory

    public var body: some View {
        hText(text, style: fieldSize == .large ? .body1 : .label)
            .fixedSize(horizontal: sizeCategory != .large ? false : true, vertical: false)
            .foregroundColor(color.pillTextColor(level: colorLevel))
            .modifier(
                PillModifier(
                    color: color,
                    colorLevel: colorLevel,
                    style: fieldSize == .large ? .body1 : .label
                )
            )
    }

    struct PillModifier: ViewModifier {
        let color: PillColor
        let colorLevel: PillColor.PillColorLevel
        let style: HFontTextStyle
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
            color.pillBackgroundColor(level: colorLevel)
        }

        private var getHorizontalPadding: CGFloat {
            var padding: CGFloat = .padding12
            if fieldSize == .small {
                padding = .padding6
            } else if fieldSize == .medium {
                padding = .padding10
            }
            return padding
        }

        private var getTopPadding: CGFloat {
            var padding: CGFloat = 7
            if fieldSize == .small {
                padding = 3
            } else if fieldSize == .medium {
                padding = 6.5
            }
            return padding
        }

        private var getBottomPadding: CGFloat {
            var padding: CGFloat = 9
            if fieldSize == .small {
                padding = 3
            } else if fieldSize == .medium {
                padding = 7.5
            }
            return padding
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
}
