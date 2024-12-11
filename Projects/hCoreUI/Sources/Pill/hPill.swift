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

    public var body: some View {
        hText(text, style: fieldSize == .large ? .body1 : .label)
            .fixedSize()
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
                .padding(.horizontal, getHorizontalPadding * style.multiplier)
                .padding(.top, getTopPadding * style.multiplier)
                .padding(.bottom, getBottomPadding * style.multiplier)
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
    case grey(translucent: Bool)

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
        case let .grey(translucent):
            switch level {
            case .one:
                if translucent {
                    hSurfaceColor.Translucent.primary
                } else {
                    hSurfaceColor.Opaque.primary
                }
            case .two:
                if translucent {
                    hSurfaceColor.Translucent.secondary
                } else {
                    hSurfaceColor.Opaque.secondary
                }
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
                    color: .grey(translucent: false)
                )

                hPill(
                    text: "Highlight label",
                    color: .grey(translucent: false)
                )
                .hFieldSize(.medium)

                hPill(
                    text: "Highlight label",
                    color: .grey(translucent: false)
                )
                .hFieldSize(.small)
            }
            HStack {
                hPill(
                    text: "Highlight label",
                    color: .grey(translucent: false),
                    colorLevel: .two
                )

                hPill(
                    text: "Highlight label",
                    color: .grey(translucent: false),
                    colorLevel: .two
                )
                .hFieldSize(.medium)

                hPill(
                    text: "Highlight label",
                    color: .grey(translucent: false),
                    colorLevel: .two
                )
                .hFieldSize(.small)
            }
            HStack {
                hPill(
                    text: "Highlight label",
                    color: .grey(translucent: false),
                    colorLevel: .three
                )

                hPill(
                    text: "Highlight label",
                    color: .grey(translucent: false),
                    colorLevel: .three
                )
                .hFieldSize(.medium)

                hPill(
                    text: "Highlight label",
                    color: .grey(translucent: false),
                    colorLevel: .three
                )
                .hFieldSize(.small)
            }
        }
    }
}
