import Foundation
import Runtime
import SwiftUI

private struct EnvironmentUserInterfaceLevel: EnvironmentKey {
    static let defaultValue: UIUserInterfaceLevel = .base
}

public struct hBackgroundColorNew {
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

public struct hGrayscaleColorNew {

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
            Color(hexString: "F0F0F0")
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
}

public struct hOverlayColorNew {
}

public struct hLabelColorNew {
}

public struct hTintColorNew {
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
}

public struct hSeparatorColorNew {
}
