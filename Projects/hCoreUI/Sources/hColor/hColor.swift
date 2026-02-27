import Foundation
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

    var asCgColor: CGColor { get }

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

@MainActor
extension Shape {
    public func fill<S>(_ content: S, style _: FillStyle = FillStyle()) -> some View where S: hColor {
        ShapeEnvironmentRedraw { colorScheme, userInterfaceLevel in
            self.fill(content.colorFor(colorScheme, userInterfaceLevel).color)
        }
    }

    public func fill2<S>(_ content: S, _: S, style _: FillStyle = FillStyle()) -> some View where S: hColor {
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

@MainActor
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
        light = hColorBase(always)
        dark = hColorBase(always)
    }

    public func colorFor(_ scheme: ColorScheme, _ level: UIUserInterfaceLevel) -> hColorBase {
        if scheme == .light {
            return light.colorFor(scheme, level)
        } else {
            return dark.colorFor(scheme, level)
        }
    }

    public var asCgColor: CGColor {
        let scheme: ColorScheme = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        return colorFor(scheme, .base).color.uiColor().cgColor
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
        color.ignoresSafeArea()
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
        modifier(hColorViewModifier(color: color, colorType: .foregroundColor))
    }

    public func border<Color: hColor>(_ color: Color?, width: CGFloat = 0) -> some View {
        modifier(hColorViewModifier(color: color, colorType: .border(width: width)))
    }
}

extension View {
    public func tint<Color: hColor>(_ color: Color?) -> some View {
        modifier(hColorViewModifier(color: color, colorType: .tintColor))
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
        base = hColorBase(always)
        elevated = hColorBase(always)
    }

    public func colorFor(_ scheme: ColorScheme, _ level: UIUserInterfaceLevel) -> hColorBase {
        if level == .elevated {
            return elevated.colorFor(scheme, level)
        } else {
            return base.colorFor(scheme, level)
        }
    }

    public var asCgColor: CGColor {
        let scheme: ColorScheme = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        return colorFor(scheme, .base).color.uiColor().cgColor
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

    public func colorFor(_: ColorScheme, _: UIUserInterfaceLevel) -> hColorBase {
        self
    }

    public var asCgColor: CGColor {
        let scheme: ColorScheme = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        return colorFor(scheme, .base).color.uiColor().cgColor
    }

    public func opacity(_ opacity: Double) -> some hColor {
        hColorBase(color.opacity(opacity))
    }

    public var inverted: hColorBase {
        self
    }

    public var color: Color

    public var body: some View {
        color
    }
}

@MainActor
public struct hTextColor {
    @MainActor
    public struct Opaque {
        public static var primary: some hColor {
            hColorScheme(
                light: hGrayscaleOpaqueColor.black,
                dark: hGrayscaleOpaqueColor.white
            )
        }

        public static var negative: some hColor {
            hTextColor.Opaque.primary.inverted
        }

        public static var secondary: some hColor {
            hColorScheme(
                light: hGrayscaleOpaqueColor.greyScale700,
                dark: hGrayscaleOpaqueColor.greyScale500
            )
        }

        public static var accordion: some hColor {
            hColorScheme(
                light: hGrayscaleOpaqueColor.greyScale750,
                dark: hGrayscaleOpaqueColor.greyScale450
            )
        }

        public static var tertiary: some hColor {
            hColorScheme(
                light: hGrayscaleOpaqueColor.greyScale500,
                dark: hGrayscaleOpaqueColor.greyScale700
            )
        }

        public static var disabled: some hColor {
            hColorScheme(
                light: hGrayscaleOpaqueColor.greyScale400,
                dark: hGrayscaleOpaqueColor.greyScale800
            )
        }

        public static var white: some hColor {
            hGrayscaleOpaqueColor.white
        }

        public static var black: some hColor {
            hGrayscaleOpaqueColor.black
        }
    }

    @MainActor
    public struct Translucent {
        public static var primary: some hColor {
            hColorScheme(
                light: hGrayscaleTranslucentLight.black,
                dark: hGrayscaleTranslucentDark.white
            )
        }

        public static var negative: some hColor {
            hColorScheme(
                light: hGrayscaleTranslucentLight.white,
                dark: hGrayscaleTranslucentDark.black
            )
        }

        public static var secondary: some hColor {
            hColorScheme(
                light: hGrayscaleTranslucentLight.greyScaleTranslucent700,
                dark: hGrayscaleTranslucentDark.greyScaleTranslucent500
            )
        }

        public static var accordion: some hColor {
            hColorScheme(
                light: hGrayscaleTranslucentLight.greyScaleTranslucent750,
                dark: hGrayscaleTranslucentDark.greyScaleTranslucent450
            )
        }

        public static var tertiary: some hColor {
            hColorScheme(
                light: hGrayscaleTranslucentLight.greyScaleTranslucent500,
                dark: hGrayscaleTranslucentDark.greyScaleTranslucent700
            )
        }

        public static var disabled: some hColor {
            hColorScheme(
                light: hGrayscaleTranslucentLight.greyScaleTranslucent400,
                dark: hGrayscaleTranslucentDark.greyScaleTranslucent800
            )
        }

        public static var black: some hColor {
            hColorScheme(
                light: hGrayscaleTranslucentLight.black,
                dark: hGrayscaleTranslucentDark.black
            )
        }

        public static var white: some hColor {
            hColorScheme(
                light: hGrayscaleTranslucentLight.white,
                dark: hGrayscaleTranslucentDark.white
            )
        }
    }

    @MainActor
    public struct Color {
        public static var action: some hColor {
            hRedColor.red600
        }

        public static var link: some hColor {
            hBlueColor.blue600
        }
    }
}

@MainActor
public protocol hButtonColor {
    var resting: any hColor { get }
    var hover: any hColor { get }
    var disabled: any hColor { get }
}

public struct Primary: hButtonColor {
    public var resting: any hColor {
        hColorScheme(
            light: hGrayscaleOpaqueColor.black,
            dark: hGrayscaleOpaqueColor.white
        )
    }

    public var hover: any hColor {
        hColorScheme(
            light: hGrayscaleTranslucentDark.greyScaleTranslucent900,
            dark: hGrayscaleTranslucentLight.greyScaleTranslucent200
        )
    }

    public var disabled: any hColor {
        hColorScheme(
            light: hGrayscaleOpaqueColor.greyScale100,
            dark: hGrayscaleOpaqueColor.greyScale900
        )
    }
}

public struct PrimaryAlt: hButtonColor {
    public init() {}
    public var resting: any hColor {
        hColorScheme(
            light: hGreenColor.green100,
            dark: hGreenColor.green200
        )
    }

    public var hover: any hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent100,
            dark: hGrayscaleTranslucentLight.greyScaleTranslucent200
        )
    }

    public var disabled: any hColor {
        hColorScheme(
            light: hGrayscaleOpaqueColor.greyScale100,
            dark: hGrayscaleOpaqueColor.greyScale900
        )
    }
}

public struct Secondary: hButtonColor {
    public var resting: any hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent100,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent900
        )
    }

    public var hover: any hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent100,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent900
        )
    }

    public var disabled: any hColor {
        hColorScheme(
            light: hGrayscaleOpaqueColor.greyScale100,
            dark: hGrayscaleOpaqueColor.greyScale900
        )
    }
}

public struct SecondaryAlt: hButtonColor {
    public var resting: any hColor {
        hColorScheme(
            light: hGrayscaleOpaqueColor.white,
            dark: hGrayscaleOpaqueColor.black
        )
    }

    public var hover: any hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent500,
            dark: hGrayscaleTranslucentLight.greyScaleTranslucent800
        )
    }

    public var disabled: any hColor {
        hColorScheme(
            light: hGrayscaleOpaqueColor.greyScale100,
            dark: hGrayscaleOpaqueColor.greyScale900
        )
    }
}

public struct Ghost: hButtonColor {
    public var resting: any hColor {
        hColorScheme(
            light: hGrayscaleTranslucent.transparent,
            dark: hGrayscaleTranslucent.transparent
        )
    }

    public var hover: any hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent100,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent900
        )
    }

    public var disabled: any hColor {
        hColorScheme(
            light: hGrayscaleTranslucent.transparent,
            dark: hGrayscaleTranslucent.transparent
        )
    }
}

@MainActor
public struct hFillColor {
    @MainActor
    public struct Opaque {
        public static var primary: some hColor {
            hColorScheme(
                light: hGrayscaleOpaqueColor.black,
                dark: hGrayscaleOpaqueColor.white
            )
        }

        public static var secondary: some hColor {
            hColorScheme(
                light: hGrayscaleOpaqueColor.greyScale700,
                dark: hGrayscaleOpaqueColor.greyScale500
            )
        }

        public static var tertiary: some hColor {
            hColorScheme(
                light: hGrayscaleOpaqueColor.greyScale500,
                dark: hGrayscaleOpaqueColor.greyScale700
            )
        }

        public static var disabled: some hColor {
            hColorScheme(
                light: hGrayscaleOpaqueColor.greyScale400,
                dark: hGrayscaleOpaqueColor.greyScale800
            )
        }

        public static var negative: some hColor {
            hColorScheme(
                light: hGrayscaleOpaqueColor.white,
                dark: hGrayscaleOpaqueColor.black
            )
        }

        public static var black: some hColor {
            hGrayscaleOpaqueColor.black
        }

        public static var white: some hColor {
            hGrayscaleOpaqueColor.white
        }
    }

    @MainActor
    public struct Translucent {
        public static var primary: some hColor {
            hColorScheme(
                light: hGrayscaleTranslucentLight.black,
                dark: hGrayscaleTranslucentDark.white
            )
        }

        public static var secondary: some hColor {
            hColorScheme(
                light: hGrayscaleTranslucentLight.greyScaleTranslucent700,
                dark: hGrayscaleTranslucentDark.greyScaleTranslucent500
            )
        }

        public static var tertiary: some hColor {
            hColorScheme(
                light: hGrayscaleTranslucentLight.greyScaleTranslucent500,
                dark: hGrayscaleTranslucentDark.greyScaleTranslucent700
            )
        }

        public static var disabled: some hColor {
            hColorScheme(
                light: hGrayscaleTranslucentLight.greyScaleTranslucent400,
                dark: hGrayscaleTranslucentDark.greyScaleTranslucent800
            )
        }

        public static var negative: some hColor {
            hColorScheme(
                light: Color(hexString: "#FFFFFF").opacity(0.98),
                dark: Color(hexString: "#000000").opacity(0.928)
            )
        }

        public static var black: some hColor {
            hGrayscaleTranslucent.black
        }

        public static var white: some hColor {
            hGrayscaleTranslucent.white
        }
    }
}

@MainActor
public struct hSurfaceColor {
    @MainActor
    public struct Opaque {
        public static var primary: some hColor {
            hColorScheme(
                light: hGrayscaleOpaqueColor.greyScale100,
                dark: hGrayscaleOpaqueColor.greyScale900
            )
        }

        public static var secondary: some hColor {
            hColorScheme(
                light: hGrayscaleOpaqueColor.greyScale200,
                dark: hGrayscaleOpaqueColor.greyScale800
            )
        }
    }

    @MainActor
    public struct Translucent {
        public static var primary: some hColor {
            hColorScheme(
                light: hGrayscaleTranslucentLight.greyScaleTranslucent100,
                dark: hGrayscaleTranslucentDark.greyScaleTranslucent900
            )
        }

        public static var secondary: some hColor {
            hColorScheme(
                light: hGrayscaleTranslucentLight.greyScaleTranslucent200,
                dark: hGrayscaleTranslucentDark.greyScaleTranslucent800
            )
        }

        public static var highLight: some hColor {
            hColorScheme(
                light: hGrayscaleTranslucent.greyScaleTranslucent50,
                dark: hGrayscaleTranslucent.greyScaleTranslucent900
            )
        }
    }
}

@MainActor
public struct hBackgroundColor {
    public static var primary: some hColor {
        hColorScheme(
            light: hGrayscaleOpaqueColor.white,
            dark: hGrayscaleOpaqueColor.black
        )
    }

    public static var negative: some hColor {
        hColorScheme(
            light: hGrayscaleOpaqueColor.black,
            dark: hGrayscaleOpaqueColor.white
        )
    }

    public static var frosted: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.white,
            dark: hGrayscaleTranslucentDark.black
        )
    }

    public static var black: some hColor {
        hGrayscaleOpaqueColor.black
    }

    public static var white: some hColor {
        hGrayscaleOpaqueColor.white
    }

    public static var clear: some hColor {
        hColorScheme(
            light: Color.clear,
            dark: Color.clear
        )
    }
}

@MainActor
public struct hBorderColor {
    public static var primary: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent200,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent900
        )
    }

    public static var secondary: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent300,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent900
        )
    }

    public static var highlight: some hColor {
        hGrayscaleTranslucentLight.greyScaleTranslucent200
    }
}

@MainActor
public struct hSignalColor {
    @MainActor
    public struct Red {
        public static var fill: some hColor {
            hColorScheme(
                light: hRedColor.red100,
                dark: hRedColor.red200
            )
        }

        public static var highlight: some hColor {
            hColorScheme(
                light: hRedColor.red300,
                dark: hRedColor.red500
            )
        }

        public static var element: some hColor {
            hColorScheme(
                light: hRedColor.red600,
                dark: hRedColor.red650
            )
        }

        public static var text: some hColor {
            hColorScheme(
                light: hRedColor.red800,
                dark: hRedColor.red900
            )
        }
    }

    @MainActor
    public struct Amber {
        public static var fill: some hColor {
            hColorScheme(
                light: hAmberColor.amber100,
                dark: hAmberColor.amber200
            )
        }

        public static var highLight: some hColor {
            hColorScheme(
                light: hAmberColor.amber300,
                dark: hAmberColor.amber500
            )
        }

        public static var element: some hColor {
            hColorScheme(
                light: hAmberColor.amber600,
                dark: hAmberColor.amber650
            )
        }

        public static var text: some hColor {
            hColorScheme(
                light: hAmberColor.amber800,
                dark: hAmberColor.amber900
            )
        }
    }

    @MainActor
    public struct Green {
        public static var fill: some hColor {
            hColorScheme(
                light: hGreenColor.green100,
                dark: hGreenColor.green200
            )
        }

        public static var highlight: some hColor {
            hColorScheme(
                light: hGreenColor.green300,
                dark: hGreenColor.green500
            )
        }

        public static var element: some hColor {
            hColorScheme(
                light: hGreenColor.green600,
                dark: hGreenColor.green650
            )
        }

        public static var text: some hColor {
            hColorScheme(
                light: hGreenColor.green800,
                dark: hGreenColor.green900
            )
        }
    }

    @MainActor
    public struct Blue {
        public static var fill: some hColor {
            hColorScheme(
                light: hBlueColor.blue100,
                dark: hBlueColor.blue200
            )
        }

        public static var highLight: some hColor {
            hColorScheme(
                light: hBlueColor.blue300,
                dark: hBlueColor.blue500
            )
        }

        public static var element: some hColor {
            hColorScheme(
                light: hBlueColor.blue600,
                dark: hBlueColor.blue650
            )
        }

        public static var text: some hColor {
            hColorScheme(
                light: hBlueColor.blue800,
                dark: hBlueColor.blue900
            )
        }

        public static var firstVet: some hColor {
            hColorScheme(
                Color(hexString: "0062FF")
            )
        }
    }

    @MainActor
    public struct Grey {
        public static var element: some hColor {
            hColorScheme(
                light: hGrayscaleOpaqueColor.greyScale700,
                dark: hGrayscaleOpaqueColor.greyScale750
            )
        }
    }
}

@MainActor
public struct hPerilColor {
    @MainActor
    public struct Purple {
        public static var fillThree: some hColor {
            hColorScheme(
                light: hPurpleColor.purple700,
                dark: hPurpleColor.purple700
            )
        }
    }
}

@MainActor
public struct hHighlightColor {
    @MainActor
    public struct Pink {
        public static var fillOne: some hColor {
            hColorScheme(
                light: hPinkColor.pink100,
                dark: hPinkColor.pink200
            )
        }

        public static var fillTwo: some hColor {
            hColorScheme(
                light: hPinkColor.pink200,
                dark: hPinkColor.pink300
            )
        }

        public static var fillThree: some hColor {
            hColorScheme(
                light: hPinkColor.pink300,
                dark: hPinkColor.pink500
            )
        }
    }

    @MainActor
    public struct Yellow {
        public static var fillOne: some hColor {
            hColorScheme(
                light: hYellowColor.yellow100,
                dark: hYellowColor.yellow200
            )
        }

        public static var fillTwo: some hColor {
            hColorScheme(
                light: hYellowColor.yellow200,
                dark: hYellowColor.yellow300
            )
        }

        public static var fillThree: some hColor {
            hColorScheme(
                light: hYellowColor.yellow300,
                dark: hYellowColor.yellow500
            )
        }
    }

    @MainActor
    public struct Green {
        public static var fillOne: some hColor {
            hColorScheme(
                light: hGreenColor.green100,
                dark: hGreenColor.green200
            )
        }

        public static var fillTwo: some hColor {
            hColorScheme(
                light: hGreenColor.green200,
                dark: hGreenColor.green300
            )
        }

        public static var fillThree: some hColor {
            hColorScheme(
                light: hGreenColor.green300,
                dark: hGreenColor.green500
            )
        }
    }

    @MainActor
    public struct Teal {
        public static var fillOne: some hColor {
            hColorScheme(
                light: hTealColor.teal100,
                dark: hTealColor.teal200
            )
        }

        public static var fillTwo: some hColor {
            hColorScheme(
                light: hTealColor.teal200,
                dark: hTealColor.teal300
            )
        }

        public static var fillThree: some hColor {
            hColorScheme(
                light: hTealColor.teal300,
                dark: hTealColor.teal500
            )
        }
    }

    @MainActor
    public struct Blue {
        public static var fillOne: some hColor {
            hColorScheme(
                light: hBlueColor.blue100,
                dark: hBlueColor.blue200
            )
        }

        public static var fillTwo: some hColor {
            hColorScheme(
                light: hBlueColor.blue200,
                dark: hBlueColor.blue300
            )
        }

        public static var fillThree: some hColor {
            hColorScheme(
                light: hBlueColor.blue300,
                dark: hBlueColor.blue500
            )
        }
    }

    @MainActor
    public struct Purple {
        public static var fillOne: some hColor {
            hColorScheme(
                light: hPurpleColor.purple100,
                dark: hPurpleColor.purple200
            )
        }

        public static var fillTwo: some hColor {
            hColorScheme(
                light: hPurpleColor.purple200,
                dark: hPurpleColor.purple300
            )
        }

        public static var fillThree: some hColor {
            hColorScheme(
                light: hPurpleColor.purple300,
                dark: hPurpleColor.purple500
            )
        }
    }

    @MainActor
    public struct Amber {
        public static var fillOne: some hColor {
            hColorScheme(
                light: hAmberColor.amber100,
                dark: hAmberColor.amber200
            )
        }

        public static var fillTwo: some hColor {
            hColorScheme(
                light: hAmberColor.amber200,
                dark: hAmberColor.amber300
            )
        }

        public static var fillThree: some hColor {
            hColorScheme(
                light: hAmberColor.amber300,
                dark: hAmberColor.amber500
            )
        }
    }

    @MainActor
    public struct Red {
        public static var fillOne: some hColor {
            hColorScheme(
                light: hRedColor.red100,
                dark: hRedColor.red200
            )
        }

        public static var fillTwo: some hColor {
            hColorScheme(
                light: hRedColor.red200,
                dark: hRedColor.red300
            )
        }

        public static var fillThree: some hColor {
            hColorScheme(
                light: hRedColor.red300,
                dark: hRedColor.red500
            )
        }
    }
}

@MainActor
public struct hGrayscaleOpaqueColor {
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

    public static var black: some hColor {
        hColorScheme(
            Color(hexString: "121212")
        )
    }

    public static var white: some hColor {
        hColorScheme(
            Color(hexString: "FAFAFA")
        )
    }
}

@MainActor
public struct hGrayscaleTranslucentLight {
    public static var greyScaleTranslucent50: some hColor {
        hColorScheme(
            Color(hexString: "#121212").opacity(0.02)
        )
    }

    public static var greyScaleTranslucent100: some hColor {
        hColorScheme(
            Color(hexString: "#121212").opacity(0.045)
        )
    }

    public static var greyScaleTranslucent200: some hColor {
        hColorScheme(
            Color(hexString: "#121212").opacity(0.068)
        )
    }

    public static var greyScaleTranslucent300: some hColor {
        hColorScheme(
            Color(hexString: "#121212").opacity(0.112)
        )
    }

    public static var greyScaleTranslucent400: some hColor {
        hColorScheme(
            Color(hexString: "#121212").opacity(0.185)
        )
    }

    public static var greyScaleTranslucent450: some hColor {
        hColorScheme(
            Color(hexString: "#121212").opacity(0.227)
        )
    }

    public static var greyScaleTranslucent500: some hColor {
        hColorScheme(
            Color(hexString: "#121212").opacity(0.3)
        )
    }

    public static var greyScaleTranslucent600: some hColor {
        hColorScheme(
            Color(hexString: "#121212").opacity(0.43)
        )
    }

    public static var greyScaleTranslucent700: some hColor {
        hColorScheme(
            Color(hexString: "#121212").opacity(0.595)
        )
    }

    public static var greyScaleTranslucent750: some hColor {
        hColorScheme(
            Color(hexString: "#121212").opacity(0.663)
        )
    }

    public static var greyScaleTranslucent800: some hColor {
        hColorScheme(
            Color(hexString: "#121212").opacity(0.734)
        )
    }

    public static var greyScaleTranslucent900: some hColor {
        hColorScheme(
            Color(hexString: "#121212").opacity(0.87)
        )
    }

    public static var black: some hColor {
        hColorScheme(
            Color(hexString: "#000000").opacity(0.928)
        )
    }

    public static var white: some hColor {
        hColorScheme(
            Color(hexString: "#121212").opacity(0.002)
        )
    }
}

@MainActor
public struct hGrayscaleTranslucentDark {
    public static var greyScaleTranslucent50: some hColor {
        hColorScheme(
            Color(hexString: "#FAFAFA").opacity(0.98)
        )
    }

    public static var greyScaleTranslucent100: some hColor {
        hColorScheme(
            Color(hexString: "#FAFAFA").opacity(0.957)
        )
    }

    public static var greyScaleTranslucent200: some hColor {
        hColorScheme(
            Color(hexString: "#FAFAFA").opacity(0.93)
        )
    }

    public static var greyScaleTranslucent300: some hColor {
        hColorScheme(
            Color(hexString: "#FAFAFA").opacity(0.89)
        )
    }

    public static var greyScaleTranslucent400: some hColor {
        hColorScheme(
            Color(hexString: "#FAFAFA").opacity(0.815)
        )
    }

    public static var greyScaleTranslucent450: some hColor {
        hColorScheme(
            Color(hexString: "#FAFAFA").opacity(0.772)
        )
    }

    public static var greyScaleTranslucent500: some hColor {
        hColorScheme(
            Color(hexString: "#FAFAFA").opacity(0.7)
        )
    }

    public static var greyScaleTranslucent600: some hColor {
        hColorScheme(
            Color(hexString: "#FAFAFA").opacity(0.57)
        )
    }

    public static var greyScaleTranslucent700: some hColor {
        hColorScheme(
            Color(hexString: "#FAFAFA").opacity(0.405)
        )
    }

    public static var greyScaleTranslucent750: some hColor {
        hColorScheme(
            Color(hexString: "#FAFAFA").opacity(0.335)
        )
    }

    public static var greyScaleTranslucent800: some hColor {
        hColorScheme(
            Color(hexString: "#FAFAFA").opacity(0.266)
        )
    }

    public static var greyScaleTranslucent900: some hColor {
        hColorScheme(
            Color(hexString: "#FAFAFA").opacity(0.13)
        )
    }

    public static var black: some hColor {
        hColorScheme(
            Color(hexString: "#FAFAFA").opacity(0.02)
        )
    }

    public static var white: some hColor {
        hColorScheme(
            Color(hexString: "FFFFFF").opacity(0.98)
        )
    }
}

@MainActor
public struct hGrayscaleTranslucent {
    public static var greyScaleTranslucent50: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent50,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent50
        )
    }

    public static var greyScaleTranslucent100: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent100,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent100
        )
    }

    public static var greyScaleTranslucent200: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent200,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent200
        )
    }

    public static var greyScaleTranslucent300: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent300,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent300
        )
    }

    public static var greyScaleTranslucent400: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent400,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent400
        )
    }

    public static var greyScaleTranslucent450: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent450,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent450
        )
    }

    public static var greyScaleTranslucent500: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent500,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent500
        )
    }

    public static var greyScaleTranslucent600: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent600,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent600
        )
    }

    public static var greyScaleTranslucent700: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent700,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent700
        )
    }

    public static var greyScaleTranslucent750: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent750,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent750
        )
    }

    public static var greyScaleTranslucent800: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent800,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent800
        )
    }

    public static var greyScaleTranslucent900: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.greyScaleTranslucent900,
            dark: hGrayscaleTranslucentDark.greyScaleTranslucent900
        )
    }

    public static var black: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.black,
            dark: hGrayscaleTranslucentDark.black
        )
    }

    public static var white: some hColor {
        hColorScheme(
            light: hGrayscaleTranslucentLight.white,
            dark: hGrayscaleTranslucentDark.white
        )
    }

    public static var transparent: some hColor {
        hColorScheme(
            light: Color.clear,
            dark: Color.clear
        )
    }
}

@MainActor
public struct hGreenColor {
    public static var green50: some hColor {
        hColorScheme(
            Color(hexString: "E1FFCC")
        )
    }

    public static var green100: some hColor {
        hColorScheme(
            Color(hexString: "D4F5BC")
        )
    }

    public static var green200: some hColor {
        hColorScheme(
            Color(hexString: "C7EBAD")
        )
    }

    public static var green300: some hColor {
        hColorScheme(
            Color(hexString: "C0DFAA")
        )
    }

    public static var green400: some hColor {
        hColorScheme(
            Color(hexString: "B8D7A2")
        )
    }

    public static var green500: some hColor {
        hColorScheme(
            Color(hexString: "B1CF9B")
        )
    }

    public static var green600: some hColor {
        hColorScheme(
            Color(hexString: "24CC5C")
        )
    }

    public static var green650: some hColor {
        hColorScheme(
            Color(hexString: "20B652")
        )
    }

    public static var green700: some hColor {
        hColorScheme(
            Color(hexString: "6F8A5C")
        )
    }

    public static var green800: some hColor {
        hColorScheme(
            Color(hexString: "4F6440")
        )
    }

    public static var green900: some hColor {
        hColorScheme(
            Color(hexString: "35432B")
        )
    }
}

@MainActor
public struct hYellowColor {
    public static var yellow50: some hColor {
        hColorScheme(
            Color(hexString: "FFFBCC")
        )
    }

    public static var yellow100: some hColor {
        hColorScheme(
            Color(hexString: "FAF5BD")
        )
    }

    public static var yellow200: some hColor {
        hColorScheme(
            Color(hexString: "F0EBAD")
        )
    }

    public static var yellow300: some hColor {
        hColorScheme(
            Color(hexString: "E3DEA0")
        )
    }

    public static var yellow400: some hColor {
        hColorScheme(
            Color(hexString: "DDD798")
        )
    }

    public static var yellow500: some hColor {
        hColorScheme(
            Color(hexString: "D5CF90")
        )
    }

    public static var yellow600: some hColor {
        hColorScheme(
            Color(hexString: "FFF266")
        )
    }

    public static var yellow650: some hColor {
        hColorScheme(
            Color(hexString: "FFEE33")
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

@MainActor
public struct hAmberColor {
    public static var amber50: some hColor {
        hColorScheme(
            Color(hexString: "FFF1CC")
        )
    }

    public static var amber100: some hColor {
        hColorScheme(
            Color(hexString: "FDEAB4")
        )
    }

    public static var amber200: some hColor {
        hColorScheme(
            Color(hexString: "FAE19E")
        )
    }

    public static var amber300: some hColor {
        hColorScheme(
            Color(hexString: "F6DC92")
        )
    }

    public static var amber400: some hColor {
        hColorScheme(
            Color(hexString: "F2D588")
        )
    }

    public static var amber500: some hColor {
        hColorScheme(
            Color(hexString: "EDCF7E")
        )
    }

    public static var amber600: some hColor {
        hColorScheme(
            Color(hexString: "FFBB00")
        )
    }

    public static var amber650: some hColor {
        hColorScheme(
            Color(hexString: "F5B400")
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
}

@MainActor
public struct hRedColor {
    public static var red50: some hColor {
        hColorScheme(
            Color(hexString: "FFEEEB")
        )
    }

    public static var red100: some hColor {
        hColorScheme(
            Color(hexString: "FEE2DE")
        )
    }

    public static var red200: some hColor {
        hColorScheme(
            Color(hexString: "F9CEC8")
        )
    }

    public static var red300: some hColor {
        hColorScheme(
            Color(hexString: "EFBFB8")
        )
    }

    public static var red400: some hColor {
        hColorScheme(
            Color(hexString: "E8B7B0")
        )
    }

    public static var red500: some hColor {
        hColorScheme(
            Color(hexString: "E2AFA7")
        )
    }

    public static var red600: some hColor {
        hColorScheme(
            Color(hexString: "FF513A")
        )
    }

    public static var red650: some hColor {
        hColorScheme(
            Color(hexString: "FF391F")
        )
    }

    public static var red700: some hColor {
        hColorScheme(
            Color(hexString: "C45F4F")
        )
    }

    public static var red800: some hColor {
        hColorScheme(
            Color(hexString: "AC311E")
        )
    }

    public static var red900: some hColor {
        hColorScheme(
            Color(hexString: "6E190C")
        )
    }
}

@MainActor
public struct hPinkColor {
    public static var pink50: some hColor {
        hColorScheme(
            Color(hexString: "FFF5FB")
        )
    }

    public static var pink100: some hColor {
        hColorScheme(
            Color(hexString: "FCE9F4")
        )
    }

    public static var pink200: some hColor {
        hColorScheme(
            Color(hexString: "F5D6E9")
        )
    }

    public static var pink300: some hColor {
        hColorScheme(
            Color(hexString: "EAC8DD")
        )
    }

    public static var pink400: some hColor {
        hColorScheme(
            Color(hexString: "E3BFD5")
        )
    }

    public static var pink500: some hColor {
        hColorScheme(
            Color(hexString: "DCB7CE")
        )
    }

    public static var pink600: some hColor {
        hColorScheme(
            Color(hexString: "EB66B8")
        )
    }

    public static var pink650: some hColor {
        hColorScheme(
            Color(hexString: "E84AAB")
        )
    }

    public static var pink700: some hColor {
        hColorScheme(
            Color(hexString: "97517C")
        )
    }

    public static var pink800: some hColor {
        hColorScheme(
            Color(hexString: "76325B")
        )
    }

    public static var pink900: some hColor {
        hColorScheme(
            Color(hexString: "602F4D")
        )
    }
}

@MainActor
public struct hPurpleColor {
    public static var purple50: some hColor {
        hColorScheme(
            Color(hexString: "F9F5FF")
        )
    }

    public static var purple100: some hColor {
        hColorScheme(
            Color(hexString: "EADEFB")
        )
    }

    public static var purple200: some hColor {
        hColorScheme(
            Color(hexString: "DDCDF4")
        )
    }

    public static var purple300: some hColor {
        hColorScheme(
            Color(hexString: "D0BFE8")
        )
    }

    public static var purple400: some hColor {
        hColorScheme(
            Color(hexString: "C8B6E2")
        )
    }

    public static var purple500: some hColor {
        hColorScheme(
            Color(hexString: "C1AEDB")
        )
    }

    public static var purple600: some hColor {
        hColorScheme(
            Color(hexString: "8F3EFF")
        )
    }

    public static var purple650: some hColor {
        hColorScheme(
            Color(hexString: "8024FF")
        )
    }

    public static var purple700: some hColor {
        hColorScheme(
            Color(hexString: "6D5A87")
        )
    }

    public static var purple800: some hColor {
        hColorScheme(
            Color(hexString: "54446A")
        )
    }

    public static var purple900: some hColor {
        hColorScheme(
            Color(hexString: "3D2D53")
        )
    }
}

@MainActor
public struct hBlueColor {
    public static var blue50: some hColor {
        hColorScheme(
            Color(hexString: "E5F6FF")
        )
    }

    public static var blue100: some hColor {
        hColorScheme(
            Color(hexString: "D0ECFB")
        )
    }

    public static var blue200: some hColor {
        hColorScheme(
            Color(hexString: "BEE1F4")
        )
    }

    public static var blue300: some hColor {
        hColorScheme(
            Color(hexString: "B0D4E8")
        )
    }

    public static var blue400: some hColor {
        hColorScheme(
            Color(hexString: "A7CDE2")
        )
    }

    public static var blue500: some hColor {
        hColorScheme(
            Color(hexString: "9FC6DB")
        )
    }

    public static var blue600: some hColor {
        hColorScheme(
            Color(hexString: "51BFFB")
        )
    }

    public static var blue650: some hColor {
        hColorScheme(
            Color(hexString: "1FA9F9")
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
            Color(hexString: "1F3E5C")
        )
    }
}

@MainActor
public struct hTealColor {
    public static var teal50: some hColor {
        hColorScheme(
            Color(hexString: "EBFFFD")
        )
    }

    public static var teal100: some hColor {
        hColorScheme(
            Color(hexString: "D4F7F4")
        )
    }

    public static var teal200: some hColor {
        hColorScheme(
            Color(hexString: "C4EEEA")
        )
    }

    public static var teal300: some hColor {
        hColorScheme(
            Color(hexString: "B8E0DD")
        )
    }

    public static var teal400: some hColor {
        hColorScheme(
            Color(hexString: "B0D9DB")
        )
    }

    public static var teal500: some hColor {
        hColorScheme(
            Color(hexString: "A9D1CD")
        )
    }

    public static var teal600: some hColor {
        hColorScheme(
            Color(hexString: "6EDCD2")
        )
    }

    public static var teal650: some hColor {
        hColorScheme(
            Color(hexString: "5BD7CD")
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

@MainActor
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
