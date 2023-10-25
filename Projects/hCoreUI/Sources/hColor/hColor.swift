import Foundation
import Runtime
import SwiftUI

private struct EnvironmentUserInterfaceLevel: EnvironmentKey {
    static let defaultValue: UIUserInterfaceLevel = .base
}

extension EnvironmentValues {
    /// signals if presentation is elevated i.e modal
    var userInterfaceLevel: UIUserInterfaceLevel {
        get { self[EnvironmentUserInterfaceLevel.self] }
        set { self[EnvironmentUserInterfaceLevel.self] = newValue }
    }
}

public protocol hColor: View {
    associatedtype Inverted: hColor
    associatedtype OpacityModified: hColor

    /// Returns color based on scheme and level
    func colorFor(_ scheme: ColorScheme, _ level: UIUserInterfaceLevel) -> hColorBase

    func opacity(_ opacity: Double) -> OpacityModified

    /// Returns a hColor where values have been flipped
    var inverted: Inverted { get }
}

public struct ShapeEnvironmentRedraw<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.userInterfaceLevel) var userInterfaceLevel

    var content: (_ colorScheme: ColorScheme, _ userInterfaceLevel: UIUserInterfaceLevel) -> Content

    init(
        @ViewBuilder _ content: @escaping (
            _ colorScheme: ColorScheme, _ userInterfaceLevel: UIUserInterfaceLevel
        ) -> Content
    ) {
        self.content = content
    }

    public var body: some View {
        content(colorScheme, userInterfaceLevel)
    }
}

extension Shape {
    public func fill<S>(_ content: S, style: FillStyle = FillStyle()) -> some View where S: hColor {
        ShapeEnvironmentRedraw { colorScheme, userInterfaceLevel in
            self.fill(content.colorFor(colorScheme, userInterfaceLevel).color)
        }
    }

    public func fill2<S>(_ content: S, _ content2: S, style: FillStyle = FillStyle()) -> some View where S: hColor {
        ShapeEnvironmentRedraw { colorScheme, userInterfaceLevel in
            self.fill(content.colorFor(colorScheme, userInterfaceLevel).color)
        }
    }

    public func stroke<S>(_ content: S, lineWidth: CGFloat = 1) -> some View where S: hColor {
        ShapeEnvironmentRedraw { colorScheme, userInterfaceLevel in
            self.stroke(content.colorFor(colorScheme, userInterfaceLevel).color, lineWidth: lineWidth)
        }
    }
}

extension InsettableShape {
    public func strokeBorder<S>(_ content: S, lineWidth: CGFloat = 1) -> some View where S: hColor {
        ShapeEnvironmentRedraw { colorScheme, userInterfaceLevel in
            self.strokeBorder(content.colorFor(colorScheme, userInterfaceLevel).color, lineWidth: lineWidth)
        }
    }
}

public struct hColorScheme<LightInnerHColor: hColor, DarkInnerHColor: hColor>: hColor {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.userInterfaceLevel) var userInterfaceLevel
    private var light: LightInnerHColor
    private var dark: DarkInnerHColor

    public init(
        light: Color,
        dark: Color
    ) where LightInnerHColor == hColorBase, DarkInnerHColor == hColorBase {
        self.light = hColorBase(light)
        self.dark = hColorBase(dark)
    }

    public init(
        light: LightInnerHColor,
        dark: DarkInnerHColor
    ) {
        self.light = light
        self.dark = dark
    }

    public init(
        _ always: Color
    ) where LightInnerHColor == hColorBase, DarkInnerHColor == hColorBase {
        self.light = hColorBase(always)
        self.dark = hColorBase(always)
    }

    public func colorFor(_ scheme: ColorScheme, _ level: UIUserInterfaceLevel) -> hColorBase {
        if scheme == .light {
            return light.colorFor(scheme, level)
        } else {
            return dark.colorFor(scheme, level)
        }
    }

    public func opacity(_ opacity: Double) -> some hColor {
        hColorScheme<LightInnerHColor.OpacityModified, DarkInnerHColor.OpacityModified>(
            light: light.opacity(opacity),
            dark: dark.opacity(opacity)
        )
    }

    public var inverted: hColorScheme<DarkInnerHColor, LightInnerHColor> {
        hColorScheme<DarkInnerHColor, LightInnerHColor>(
            light: dark,
            dark: light
        )
    }

    public var color: hColorBase {
        colorFor(colorScheme, userInterfaceLevel)
    }

    public var body: some View {
        color
    }
}

struct hColorViewModifier<Color: hColor>: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.userInterfaceLevel) var userInterfaceLevel
    var color: Color?
    var colorType: ColorType

    enum ColorType {
        case tintColor
        case foregroundColor
        case border(width: CGFloat)
    }

    func body(content: Content) -> some View {
        Group {
            switch colorType {
            case .tintColor:
                content.accentColor(color?.colorFor(colorScheme, userInterfaceLevel).color)
            case .foregroundColor:
                content.foregroundColor(color?.colorFor(colorScheme, userInterfaceLevel).color)
            case let .border(width):
                content.border(
                    color?.colorFor(colorScheme, userInterfaceLevel).color ?? SwiftUI.Color.clear,
                    width: width
                )
            }
        }
    }
}

extension View {
    public func foregroundColor<Color: hColor>(_ color: Color?) -> some View {
        self.modifier(hColorViewModifier(color: color, colorType: .foregroundColor))
    }

    public func border<Color: hColor>(_ color: Color?, width: CGFloat = 0) -> some View {
        self.modifier(hColorViewModifier(color: color, colorType: .border(width: width)))
    }
}

extension View {
    public func tint<Color: hColor>(_ color: Color?) -> some View {
        self.modifier(hColorViewModifier(color: color, colorType: .tintColor))
    }
}

public struct hColorLevel<InnerHColor: hColor>: hColor {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.userInterfaceLevel) var userInterfaceLevel

    private var base: InnerHColor
    private var elevated: InnerHColor

    init(
        base: Color,
        elevated: Color
    ) where InnerHColor == hColorBase {
        self.base = hColorBase(base)
        self.elevated = hColorBase(elevated)
    }

    init(
        base: InnerHColor,
        elevated: InnerHColor
    ) {
        self.base = base
        self.elevated = elevated
    }

    init(
        _ always: Color
    ) where InnerHColor == hColorBase {
        self.base = hColorBase(always)
        self.elevated = hColorBase(always)
    }

    public func colorFor(_ scheme: ColorScheme, _ level: UIUserInterfaceLevel) -> hColorBase {
        if level == .elevated {
            return elevated.colorFor(scheme, level)
        } else {
            return base.colorFor(scheme, level)
        }
    }

    public func opacity(_ opacity: Double) -> some hColor {
        hColorLevel<InnerHColor.OpacityModified>(
            base: base.opacity(opacity),
            elevated: elevated.opacity(opacity)
        )
    }

    public var inverted: Self {
        Self(
            base: elevated,
            elevated: base
        )
    }

    public var color: hColorBase {
        colorFor(colorScheme, userInterfaceLevel)
    }

    public var body: some View {
        color
    }
}

public struct hColorBase: hColor, View {
    public init(
        _ color: Color
    ) {
        self.color = color
    }

    public func colorFor(_ scheme: ColorScheme, _ level: UIUserInterfaceLevel) -> hColorBase {
        return self
    }

    public func opacity(_ opacity: Double) -> some hColor {
        hColorBase(self.color.opacity(opacity))
    }

    public var inverted: hColorBase {
        self
    }

    public var color: Color

    public var body: some View {
        color
    }
}

public struct hBackgroundColor {
    public static var primary: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale25,
            dark: hGrayscaleColor.greyScale1000
        )
    }

    public static var clear: some hColor {
        hColorScheme(
            light: Color.clear,
            dark: Color.clear
        )
    }
}

public struct hTextColor {
    public static var primary: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale1000,
            dark: hGrayscaleColor.greyScale25
        )
    }

    public static var negative: some hColor {
        hTextColor.primary.inverted
    }

    public static var secondary: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale700,
            dark: hGrayscaleColor.greyScale500
        )
    }

    public static var secondaryAccordion: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale750,
            dark: hGrayscaleColor.greyScale450
        )
    }

    public static var tertiary: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale500,
            dark: hGrayscaleColor.greyScale700
        )
    }

    public static var disabled: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale400,
            dark: hGrayscaleColor.greyScale800
        )

    }

    public static var primaryTranslucent: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucent.offBlackTranslucent,
            dark: hGrayscaleTranslucent.offWhiteTranslucent
        )
    }

    public static var secondaryTranslucent: some hColor {
        hGrayscaleTranslucent.greyScaleTranslucent700
    }

    public static var tertiaryTranslucent: some hColor {
        hGrayscaleTranslucent.greyScaleTranslucent500
    }
}

public struct hBorderColor {
    public static var opaqueOne: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale200,
            dark: hGrayscaleColor.greyScale900
        )
    }

    public static var opaqueTwo: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale300,
            dark: hGrayscaleColor.greyScale800
        )
    }

    public static var opaqueThree: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale700,
            dark: hGrayscaleColor.greyScale300
        )
    }

    public static var opaqueFour: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale800,
            dark: hGrayscaleColor.greyScale200
        )
    }

    public static var translucentOne: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucent.greyScaleTranslucent200,
            dark: hGrayscaleTranslucent.greyScaleTranslucent900
        )
    }

    public static var translucentTwo: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucent.greyScaleTranslucent300,
            dark: hGrayscaleTranslucent.greyScaleTranslucent800
        )
    }

    public static var translucentThree: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucent.greyScaleTranslucent700,
            dark: hGrayscaleTranslucent.greyScaleTranslucent300
        )
    }

    public static var translucentFour: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucent.greyScaleTranslucent800,
            dark: hGrayscaleTranslucent.greyScaleTranslucent200
        )
    }
}

public struct hFillColor {
    public static var opaqueOne: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale100,
            dark: hGrayscaleColor.greyScale900
        )
    }

    public static var opaqueTwo: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale300,
            dark: hGrayscaleColor.greyScale900
        )
    }

    public static var opaqueThree: some hColor {
        hGrayscaleColor.greyScale400
    }

    public static var translucentOne: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucent.greyScaleTranslucent100,
            dark: hGrayscaleColor.greyScale800
        )
    }

    public static var translucentTwo: some hColor {
        hGrayscaleTranslucent.greyScaleTranslucent300
    }

    public static var translucentThree: some hColor {
        hGrayscaleTranslucent.greyScaleTranslucent400
    }

    public static var offBlack: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale1000,
            dark: hGrayscaleColor.greyScale25
        )
    }
}

public struct hHighlightColor {
    public static var blueFillOne: some hColor {
        hBlueColor.blue100
    }

    public static var blueFillTwo: some hColor {
        hBlueColor.blue200
    }

    public static var blueFillThree: some hColor {
        hBlueColor.blue300
    }

    public static var purpleFillOne: some hColor {
        hPurpleColor.purple100
    }

    public static var purpleFillTwo: some hColor {
        hPurpleColor.purple200
    }

    public static var purpleFillThree: some hColor {
        hPurpleColor.purple300
    }

    public static var yellowFillOne: some hColor {
        hYellowColor.yellow100
    }

    public static var yellowFillTwo: some hColor {
        hYellowColor.yellow200
    }

    public static var yellowFillThree: some hColor {
        hYellowColor.yellow300
    }

    public static var tealFillOne: some hColor {
        hTealColor.teal100
    }

    public static var tealFillTwo: some hColor {
        hTealColor.teal200
    }

    public static var tealFillThree: some hColor {
        hTealColor.teal300
    }

    public static var pinkFillOne: some hColor {
        hPinkColor.pink100
    }

    public static var pinkFillTwo: some hColor {
        hPinkColor.pink200
    }

    public static var pinkFillThree: some hColor {
        hPinkColor.pink300
    }
}

public struct hSignalColor {
    public static var greenFill: some hColor {
        hColorScheme(
            light: hGreenColor.green100,
            dark: hGreenColor.green300
        )
    }

    public static var greenHighlight: some hColor {
        hColorScheme(
            light: hGreenColor.green300,
            dark: hGreenColor.green500
        )
    }

    public static var greenElement: some hColor {
        hColorScheme(
            light: hGreenColor.green600,
            dark: hGreenColor.greenDarkElement
        )
    }

    public static var greenText: some hColor {
        hColorScheme(
            light: hGreenColor.green800,
            dark: hGreenColor.green900
        )
    }

    public static var amberFill: some hColor {
        hColorScheme(
            light: hAmberColor.amber100,
            dark: hAmberColor.amber300
        )
    }

    public static var amberHighLight: some hColor {
        hColorScheme(
            light: hAmberColor.amber300,
            dark: hAmberColor.amber500
        )
    }

    public static var amberElement: some hColor {
        hColorScheme(
            light: hAmberColor.amber600,
            dark: hAmberColor.amberDarkElement
        )
    }

    public static var amberText: some hColor {
        hColorScheme(
            light: hAmberColor.amber800,
            dark: hAmberColor.amber900
        )
    }

    public static var redFill: some hColor {
        hColorScheme(
            light: hRedColor.red100,
            dark: hRedColor.red300
        )
    }

    public static var redHighlight: some hColor {
        hColorScheme(
            light: hRedColor.red300,
            dark: hRedColor.red500
        )
    }

    public static var redElement: some hColor {
        hColorScheme(
            light: hRedColor.red600,
            dark: hRedColor.redDark
        )
    }

    public static var redText: some hColor {
        hColorScheme(
            light: hRedColor.red800,
            dark: hRedColor.red900
        )
    }

    public static var blueFill: some hColor {
        hColorScheme(
            light: hBlueColor.blue100,
            dark: hBlueColor.blue300
        )
    }

    public static var blueHighLight: some hColor {
        hColorScheme(
            light: hBlueColor.blue300,
            dark: hBlueColor.blue500
        )
    }

    public static var blueElement: some hColor {
        hColorScheme(
            light: hBlueColor.blue600,
            dark: hBlueColor.blueElementDark
        )
    }

    public static var blueText: some hColor {
        hColorScheme(
            light: hBlueColor.blue800,
            dark: hBlueColor.blue900
        )
    }
}

public struct hButtonColor {
    public static var primaryDefault: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale1000,
            dark: hGrayscaleColor.greyScale25
        )
    }

    public static var primaryHover: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale900,
            dark: hGrayscaleColor.greyScale300
        )
    }

    public static var primaryDisabled: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale200,
            dark: hGrayscaleColor.greyScale900
        )
    }

    public static var primaryAltDefault: some hColor {
        hColorScheme(
            light: hGreenColor.green50,
            dark: hGreenColor.green200
        )
    }

    public static var primaryAltHover: some hColor {
        hColorScheme(
            light: hGreenColor.green200,
            dark: hGreenColor.green400
        )
    }

    public static var primaryAltDisabled: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale200,
            dark: hGrayscaleColor.greyScale900
        )
    }

    public static var secondaryDefault: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale50,
            dark: hGrayscaleColor.greyScale800
        )
    }

    public static var secondaryHover: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale300,
            dark: hGrayscaleColor.greyScale700
        )
    }

    public static var secondaryDisabled: some hColor {
        hColorScheme(
            light: hGrayscaleColor.greyScale200,
            dark: hGrayscaleColor.greyScale900
        )
    }

    public static var secondaryAltDefault: some hColor {
        hGrayscaleColor.greyScale25
    }

    public static var secondaryAltHover: some hColor {
        hGrayscaleColor.greyScale1000.opacity(0.2)
    }

    public static var secondaryAltDisabled: some hColor {
        hGrayscaleColor.greyScale200
    }
}

public struct hGrayscaleColor {
    public static var greyScale25: some hColor {
        hColorScheme(
            Color(hexString: "FAFAFA")
        )
    }

    public static var greyScale50: some hColor {
        hColorScheme(
            Color(hexString: "F5F5F5")
        )
    }

    public static var greyScale100: some hColor {
        hColorScheme(
            light: Color(hexString: "F0F0F0"),
            dark: Color(hexString: "303030")
        )
    }

    public static var greyScale200: some hColor {
        hColorScheme(
            Color(hexString: "EAEAEA")
        )
    }

    public static var greyScale300: some hColor {
        hColorScheme(
            Color(hexString: "E0E0E0")
        )
    }

    public static var greyScale400: some hColor {
        hColorScheme(
            Color(hexString: "CFCFCF")
        )
    }

    public static var greyScale450: some hColor {
        hColorScheme(
            Color(hexString: "C5C5C5")
        )
    }

    public static var greyScale500: some hColor {
        hColorScheme(
            Color(hexString: "B4B4B4")
        )
    }

    public static var greyScale600: some hColor {
        hColorScheme(
            Color(hexString: "969696")
        )
    }

    public static var greyScale700: some hColor {
        hColorScheme(
            Color(hexString: "707070")
        )
    }

    public static var greyScale750: some hColor {
        hColorScheme(
            Color(hexString: "606060")
        )
    }

    public static var greyScale800: some hColor {
        hColorScheme(
            Color(hexString: "505050")
        )
    }

    public static var greyScale900: some hColor {
        hColorScheme(
            Color(hexString: "303030")
        )
    }

    public static var greyScale1000: some hColor {
        hColorScheme(
            Color(hexString: "#121212")
        )
    }
}

public struct hGrayscaleTranslucent {
    public static var offWhiteTranslucent: some hColor {
        return hColorScheme(
            light: Color(hexString: "#121212").opacity(0.2),
            dark: Color(hexString: "FFFFFF").opacity(0.9)
        )
    }

    public static var greyScaleTranslucent50: some hColor {
        return hColorScheme(
            light: Color(hexString: "#121212").opacity(0.02),
            dark: Color(hexString: "#FAFAFA").opacity(0.98)
        )
    }

    public static var greyScaleTranslucent100: some hColor {
        return hColorScheme(
            light: Color(hexString: "#121212").opacity(0.045),
            dark: Color(hexString: "#FAFAFA").opacity(0.957)
        )
    }

    public static var greyScaleTranslucent200: some hColor {
        return hColorScheme(
            light: Color(hexString: "#121212").opacity(0.07),
            dark: Color(hexString: "#FAFAFA").opacity(0.93)
        )
    }

    public static var greyScaleTranslucent300: some hColor {
        return hColorScheme(
            light: Color(hexString: "#121212").opacity(0.11),
            dark: Color(hexString: "#FAFAFA").opacity(0.89)
        )
    }

    public static var greyScaleTranslucent400: some hColor {
        return hColorScheme(
            light: Color(hexString: "#121212").opacity(0.185),
            dark: Color(hexString: "#FAFAFA").opacity(0.815)
        )
    }

    public static var greyScaleTranslucent500: some hColor {
        return hColorScheme(
            light: Color(hexString: "#121212").opacity(0.3),
            dark: Color(hexString: "#FAFAFA").opacity(0.7)
        )
    }

    public static var greyScaleTranslucent600: some hColor {
        return hColorScheme(
            light: Color(hexString: "#121212").opacity(0.43),
            dark: Color(hexString: "#FAFAFA").opacity(0.57)
        )
    }

    public static var greyScaleTranslucent700: some hColor {
        return hColorScheme(
            light: Color(hexString: "#121212").opacity(0.595),
            dark: Color(hexString: "#FAFAFA").opacity(0.415)
        )
    }

    public static var greyScaleTranslucent800: some hColor {
        return hColorScheme(
            light: Color(hexString: "#121212").opacity(0.734),
            dark: Color(hexString: "#FAFAFA").opacity(0.266)
        )
    }

    public static var greyScaleTranslucent900: some hColor {
        return hColorScheme(
            light: Color(hexString: "#121212").opacity(0.87),
            dark: Color(hexString: "#FAFAFA").opacity(0.13)
        )
    }

    public static var offBlackTranslucent: some hColor {
        return hColorScheme(
            light: Color(hexString: "#000000").opacity(0.927),
            dark: Color(hexString: "#FAFAFA").opacity(0.02)
        )
    }
}
public struct hGreenColor {
    public static var green50: some hColor {
        hColorScheme(
            Color(hexString: "EAFFCC")
        )
    }

    public static var green100: some hColor {
        hColorScheme(
            Color(hexString: "E2F6C6")
        )
    }

    public static var green200: some hColor {
        hColorScheme(
            Color(hexString: "DAEEBD")
        )
    }

    public static var green300: some hColor {
        hColorScheme(
            Color(hexString: "D1E4B6")
        )
    }

    public static var green400: some hColor {
        hColorScheme(
            Color(hexString: "C8E3A2")
        )
    }

    public static var green500: some hColor {
        hColorScheme(
            Color(hexString: "B8D194")
        )
    }

    public static var green600: some hColor {
        hColorScheme(
            Color(hexString: "24CC5C")
        )
    }

    public static var green700: some hColor {
        hColorScheme(
            Color(hexString: "6B8A5C")
        )
    }

    public static var green800: some hColor {
        hColorScheme(
            Color(hexString: "4C6440")
        )
    }

    public static var green900: some hColor {
        hColorScheme(
            Color(hexString: "33432B")
        )
    }

    public static var greenDarkElement: some hColor {
        hColorScheme(
            Color(hexString: "20B652")
        )
    }
}

public struct hYellowColor {
    public static var yellow50: some hColor {
        hColorScheme(
            Color(hexString: "FFFBCF")
        )
    }

    public static var yellow100: some hColor {
        hColorScheme(
            Color(hexString: "F6F1C0")
        )
    }

    public static var yellow200: some hColor {
        hColorScheme(
            Color(hexString: "EBE5AD")
        )
    }

    public static var yellow300: some hColor {
        hColorScheme(
            Color(hexString: "E3DDA0")
        )
    }

    public static var yellow400: some hColor {
        hColorScheme(
            Color(hexString: "DBD593")
        )
    }

    public static var yellow500: some hColor {
        hColorScheme(
            Color(hexString: "D5CE82")
        )
    }

    public static var yellow600: some hColor {
        hColorScheme(
            Color(hexString: "FFF266")
        )
    }

    public static var yellow700: some hColor {
        hColorScheme(
            Color(hexString: "A49758")
        )
    }

    public static var yellow800: some hColor {
        hColorScheme(
            Color(hexString: "827535")
        )
    }

    public static var yellow900: some hColor {
        hColorScheme(
            Color(hexString: "5E500A")
        )
    }
}

public struct hAmberColor {
    public static var amber50: some hColor {
        hColorScheme(
            Color(hexString: "FFF4D5")
        )
    }

    public static var amber100: some hColor {
        hColorScheme(
            Color(hexString: "FBEDC5")
        )
    }

    public static var amber200: some hColor {
        hColorScheme(
            Color(hexString: "F6E5B2")
        )
    }

    public static var amber300: some hColor {
        hColorScheme(
            Color(hexString: "F5E0A3")
        )
    }

    public static var amber400: some hColor {
        hColorScheme(
            Color(hexString: "F2D98C")
        )
    }

    public static var amber500: some hColor {
        hColorScheme(
            Color(hexString: "EED077")
        )
    }

    public static var amber600: some hColor {
        hColorScheme(
            Color(hexString: "FFBF00")
        )
    }

    public static var amber700: some hColor {
        hColorScheme(
            Color(hexString: "AC7339")
        )
    }

    public static var amber800: some hColor {
        hColorScheme(
            Color(hexString: "8A4C0F")
        )
    }

    public static var amber900: some hColor {
        hColorScheme(
            Color(hexString: "6B3806")
        )
    }

    public static var amberDarkElement: some hColor {
        hColorScheme(
            Color(hexString: "E5AC00")
        )
    }
}

public struct hRedColor {
    public static var red50: some hColor {
        hColorScheme(
            Color(hexString: "FFF2F0")
        )
    }

    public static var red100: some hColor {
        hColorScheme(
            Color(hexString: "FDE8E5")
        )
    }

    public static var red200: some hColor {
        hColorScheme(
            Color(hexString: "FADFDB")
        )
    }

    public static var red300: some hColor {
        hColorScheme(
            Color(hexString: "F2CFCA")
        )
    }

    public static var red400: some hColor {
        hColorScheme(
            Color(hexString: "EEC0BA")
        )
    }

    public static var red500: some hColor {
        hColorScheme(
            Color(hexString: "E8ACA4")
        )
    }

    public static var red600: some hColor {
        hColorScheme(
            Color(hexString: "FF513A")
        )
    }

    public static var red700: some hColor {
        hColorScheme(
            Color(hexString: "C45D4F")
        )
    }

    public static var red800: some hColor {
        hColorScheme(
            Color(hexString: "AC2F1E")
        )
    }

    public static var red900: some hColor {
        hColorScheme(
            Color(hexString: "6E180C")
        )
    }

    public static var redDark: some hColor {
        hColorScheme(
            Color(hexString: "FF391F")
        )
    }
}

public struct hPinkColor {
    public static var pink50: some hColor {
        hColorScheme(
            Color(hexString: "FFF3FA")
        )
    }

    public static var pink100: some hColor {
        hColorScheme(
            Color(hexString: "FAE8F3")
        )
    }

    public static var pink200: some hColor {
        hColorScheme(
            Color(hexString: "F2D9E8")
        )
    }

    public static var pink300: some hColor {
        hColorScheme(
            Color(hexString: "ECCBDF")
        )
    }

    public static var pink400: some hColor {
        hColorScheme(
            Color(hexString: "E7B6D3")
        )
    }

    public static var pink500: some hColor {
        hColorScheme(
            Color(hexString: "DCA2C5")
        )
    }

    public static var pink600: some hColor {
        hColorScheme(
            Color(hexString: "EB65B5")
        )
    }

    public static var pink700: some hColor {
        hColorScheme(
            Color(hexString: "97517B")
        )
    }

    public static var pink800: some hColor {
        hColorScheme(
            Color(hexString: "76325B")
        )
    }

    public static var pink900: some hColor {
        hColorScheme(
            Color(hexString: "602F4C")
        )
    }
}

public struct hPurpleColor {
    public static var purple50: some hColor {
        hColorScheme(
            Color(hexString: "F6F0FF")
        )
    }

    public static var purple100: some hColor {
        hColorScheme(
            Color(hexString: "EBE3F6")
        )
    }

    public static var purple200: some hColor {
        hColorScheme(
            Color(hexString: "DDD5E9")
        )
    }

    public static var purple300: some hColor {
        hColorScheme(
            Color(hexString: "CAC0D8")
        )
    }

    public static var purple400: some hColor {
        hColorScheme(
            Color(hexString: "B6AAC6")
        )
    }

    public static var purple500: some hColor {
        hColorScheme(
            Color(hexString: "A396B6")
        )
    }

    public static var purple600: some hColor {
        hColorScheme(
            Color(hexString: "8F3EFF")
        )
    }

    public static var purple700: some hColor {
        hColorScheme(
            Color(hexString: "705A87")
        )
    }

    public static var purple800: some hColor {
        hColorScheme(
            Color(hexString: "57446A")
        )
    }

    public static var purple900: some hColor {
        hColorScheme(
            Color(hexString: "402D53")
        )
    }
}

public struct hBlueColor {
    public static var blue50: some hColor {
        hColorScheme(
            Color(hexString: "EAF7FF")
        )
    }

    public static var blue100: some hColor {
        hColorScheme(
            Color(hexString: "E0F0F9")
        )
    }

    public static var blue200: some hColor {
        hColorScheme(
            Color(hexString: "CFE5F2")
        )
    }

    public static var blue300: some hColor {
        hColorScheme(
            Color(hexString: "BDDBED")
        )
    }

    public static var blue400: some hColor {
        hColorScheme(
            Color(hexString: "A9CDE2")
        )
    }

    public static var blue500: some hColor {
        hColorScheme(
            Color(hexString: "98C2DA")
        )
    }

    public static var blue600: some hColor {
        hColorScheme(
            Color(hexString: "59BFFA")
        )
    }

    public static var blue700: some hColor {
        hColorScheme(
            Color(hexString: "4B739B")
        )
    }

    public static var blue800: some hColor {
        hColorScheme(
            Color(hexString: "30577E")
        )
    }

    public static var blue900: some hColor {
        hColorScheme(
            Color(hexString: "1F3D5C")
        )
    }

    public static var blueElementDark: some hColor {
        hColorScheme(
            Color(hexString: "3EB5F9")
        )
    }
}

public struct hTealColor {
    public static var teal50: some hColor {
        hColorScheme(
            Color(hexString: "DCFFFC")
        )
    }

    public static var teal100: some hColor {
        hColorScheme(
            Color(hexString: "DBF5F3")
        )
    }

    public static var teal200: some hColor {
        hColorScheme(
            Color(hexString: "D4EFED")
        )
    }

    public static var teal300: some hColor {
        hColorScheme(
            Color(hexString: "CBE5E3")
        )
    }

    public static var teal400: some hColor {
        hColorScheme(
            Color(hexString: "BBD7D5")
        )
    }

    public static var teal500: some hColor {
        hColorScheme(
            Color(hexString: "A4C9C6")
        )
    }

    public static var teal600: some hColor {
        hColorScheme(
            Color(hexString: "6EDCD2")
        )
    }

    public static var teal700: some hColor {
        hColorScheme(
            Color(hexString: "689B96")
        )
    }

    public static var teal800: some hColor {
        hColorScheme(
            Color(hexString: "3F7570")
        )
    }

    public static var teal900: some hColor {
        hColorScheme(
            Color(hexString: "295652")
        )
    }
}

public struct hBlurColor {
    public static var blurOne: some hColor {
        hColorScheme(
            Color(hexString: "C3CBD6")
        )
    }

    public static var blurTwo: some hColor {
        hColorScheme(
            Color(hexString: "EDCDAB")
        )
    }
}
