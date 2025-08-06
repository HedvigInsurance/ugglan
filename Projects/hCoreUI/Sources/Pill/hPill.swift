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
            .fixedSize(horizontal: sizeCategory <= .large, vertical: false)
            .foregroundColor(color.pillTextColor(level: colorLevel))
            .modifier(
                PillModifier(
                    color: color,
                    colorLevel: colorLevel
                )
            )
    }

    struct PillModifier: ViewModifier {
        let color: PillColor
        let colorLevel: PillColor.PillColorLevel
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
                .overlay(
                    RoundedRectangle(cornerRadius: getCornerRadius)
                        .stroke(hBorderColor.primary, lineWidth: 1)
                )
        }

        private var getHorizontalPadding: CGFloat {
            switch fieldSize {
            case .small:
                return .padding6
            case .medium:
                return .padding10
            case .large:
                return .padding12
            }
        }

        private var getTopPadding: CGFloat {
            switch fieldSize {
            case .small:
                return 3
            case .medium:
                return 6.5
            case .large:
                return 7
            }
        }

        private var getBottomPadding: CGFloat {
            switch fieldSize {
            case .small:
                return 3
            case .medium:
                return 7.5
            case .large:
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
            }
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
