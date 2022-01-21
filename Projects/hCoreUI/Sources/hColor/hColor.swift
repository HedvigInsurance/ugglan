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
        let baseColor = hColorScheme(
            light: Color(hexString: "F6F6F6"),
            dark: Color(hexString: "000000")
        )

        let elevatedColor = hColorScheme(
            light: Color(hexString: "FFFFFF"),
            dark: Color(hexString: "1B1B1B")
        )

        return hColorLevel(base: baseColor, elevated: elevatedColor)
    }

    public static var secondary: some hColor {
        let baseColor = hColorScheme(
            light: Color(hexString: "FAFAFA"),
            dark: Color(hexString: "1B1B1B")
        )

        let elevatedColor = hColorScheme(
            light: Color(hexString: "F6F6F6"),
            dark: Color(hexString: "2A2A2A")
        )

        return hColorLevel(base: baseColor, elevated: elevatedColor)
    }

    public static var tertiary: some hColor {
        let baseColor = hColorScheme(
            light: Color(hexString: "FFFFFF"),
            dark: Color(hexString: "2A2A2A")
        )

        let elevatedColor = hColorScheme(
            light: Color(hexString: "FFFFFF"),
            dark: Color(hexString: "505050")
        )

        return hColorLevel(base: baseColor, elevated: elevatedColor)
    }
}

public struct hGrayscaleColor {
    public static var one: some hColor {
        hColorScheme(
            Color(hexString: "EAEAEA")
        )
    }

    public static var two: some hColor {
        hColorScheme(
            Color(hexString: "AAAAAA")
        )
    }

    public static var three: some hColor {
        hColorScheme(
            Color(hexString: "777777")
        )
    }

    public static var four: some hColor {
        hColorScheme(
            Color(hexString: "505050")
        )
    }

    public static var five: some hColor {
        hColorScheme(
            Color(hexString: "252525")
        )
    }
}

public struct hOverlayColor {
    public static var pressed: some hColor {
        hColorScheme(
            light: Color(hexString: "121212").opacity(0.25),
            dark: Color(hexString: "FAFAFA").opacity(0.08)
        )
    }

    public static var pressedLavender: some hColor {
        hColorScheme(
            light: Color(hexString: "C9ABF5"),
            dark: Color(hexString: "2B203B").opacity(0.25)
        )
    }
}

public struct hLabelColor {
    public static var primary: some hColor {
        hColorScheme(
            light: Color(hexString: "121212"),
            dark: Color(hexString: "FAFAFA")
        )
    }

    public static var secondary: some hColor {
        hColorScheme(
            light: Color(hexString: "121212").opacity(0.67),
            dark: Color(hexString: "FAFAFA").opacity(0.56)
        )
    }

    public static var tertiary: some hColor {
        hColorScheme(
            light: Color(hexString: "121212").opacity(0.34),
            dark: Color(hexString: "FAFAFA").opacity(0.40)
        )
    }

    public static var quarternary: some hColor {
        hColorScheme(
            light: Color(hexString: "FAFAFA"),
            dark: Color(hexString: "FAFAFA").opacity(0.18)
        )
    }

    public static var link: some hColor {
        hColorScheme(
            light: Color(hexString: "BE9BF3"),
            dark: Color(hexString: "875EC5")
        )
    }
}

public struct hTintColor {
    public static var lavenderOne: some hColor {
        hColorScheme(
            light: Color(hexString: "C9ABF5"),
            dark: Color(hexString: "BE9BF3")
        )
    }

    public static var lavenderTwo: some hColor {
        hColorScheme(
            light: Color(hexString: "E7D6FF"),
            dark: Color(hexString: "2B203B")
        )
    }

    public static var yellowOne: some hColor {
        hColorScheme(
            light: Color(hexString: "F2C852"),
            dark: Color(hexString: "CCA42E")
        )
    }

    public static var yellowTwo: some hColor {
        hColorScheme(
            light: Color(hexString: "FAE098"),
            dark: Color(hexString: "E3B945")
        )
    }

    public static var red: some hColor {
        hColorScheme(
            light: Color(hexString: "DD2727"),
            dark: Color(hexString: "E24646")
        )
    }

    public static var orangeOne: some hColor {
        hColorScheme(
            light: Color(hexString: "FE9650"),
            dark: Color(hexString: "FE9650")
        )
    }

    public static var orangeTwo: some hColor {
        hColorScheme(
            light: Color(hexString: "FCBA8D"),
            dark: Color(hexString: "FCBA8D")
        )
    }

    public static var clear: some hColor {
        hColorScheme(
            light: Color.clear,
            dark: Color.clear
        )
    }
}

public struct hSeparatorColor {
    public static var separator: some hColor {
        hColorScheme(
            light: Color(hexString: "3C3C43").opacity(0.29),
            dark: Color(hexString: "545458").opacity(0.65)
        )
    }
}
