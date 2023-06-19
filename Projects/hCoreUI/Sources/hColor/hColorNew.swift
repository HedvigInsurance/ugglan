import Foundation
import Runtime
import SwiftUI

private struct EnvironmentUserInterfaceLevel: EnvironmentKey {
    static let defaultValue: UIUserInterfaceLevel = .base
}

public struct hBackgroundColorNew {
    public static var primary: some hColor {
        hColorScheme(
            Color(hexString: "FAFAFA")
        )
    }

    public static var secondary: some hColor {
        hGrayscaleColorNew.greyScale700
    }

    public static var inputBackground: some hColor {
        hGrayscaleColorNew.greyScale100
    }

    public static var inputBackgroundActive: some hColor {
        hGreenColorNew.green100
    }

    public static var inputBackgroundWarning: some hColor {
        hAmberColorNew.amber100
    }

    public static var semanticButton: some hColor {
        hGreenColorNew.greenSemantic
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

    public static var greyScale700: some hColor {
        hColorScheme(
            Color(hexString: "707070")
        )
    }

    public static var greyScale1000: some hColor {
        hColorScheme(
            Color(hexString: "#121212")
        )
    }
}

public struct hGrayscaleTranslucentColorNew {
    public static var offBlackTranslucent: some hColor {
        hColorScheme(
            Color(hexString: "000000").opacity(0.92)
        )
    }

    public static var offWhiteTranslucent: some hColor {
        hColorScheme(
            Color(hexString: "FAFAFA").opacity(0.6)
        )
    }

    public static var greyScaleTranslucent50: some hColor {
        hColorScheme(
            Color(hexString: "#F0F0F0").opacity(0.60)
        )
    }

    public static var greyScaleTranslucent100: some hColor {
        hColorScheme(
            Color(hexString: "EAEAEA").opacity(0.60)
        )
    }

    public static var greyScaleTranslucentBlack100: some hColor {
        hColorScheme(
            Color(hexString: "121212").opacity(0.045)
        )
    }

    public static var greyScaleTranslucent200: some hColor {
        hColorScheme(
            Color(hexString: "E0E0E0").opacity(0.60)
        )
    }

    public static var greyScaleTranslucent300: some hColor {
        hColorScheme(
            Color(hexString: "CFCFCF").opacity(0.60)
        )
    }

    public static var greyScaleTranslucent400: some hColor {
        hColorScheme(
            Color(hexString: "B4B4B4").opacity(0.60)
        )
    }

    public static var greyScaleTranslucent500: some hColor {
        hColorScheme(
            Color(hexString: "969696").opacity(0.70)
        )
    }

    public static var greyScaleTranslucent600: some hColor {
        hColorScheme(
            Color(hexString: "727272").opacity(0.74)
        )
    }

    public static var greyScaleTranslucent700: some hColor {
        hColorScheme(
            Color(hexString: "505050").opacity(0.80)
        )
    }

    public static var greyScaleTranslucent800: some hColor {
        hColorScheme(
            Color(hexString: "#303030").opacity(0.84)
        )
    }

    public static var greyScaleTranslucent900: some hColor {
        hColorScheme(
            Color(hexString: "#121212").opacity(0.87)
        )
    }

    public static var greyScaleTranslucentField: some hColor {
        hColorScheme(
            Color(hexString: "#121212").opacity(0.05)
        )
    }
}

public struct hLabelColorNew {
    public static var primary: some hColor {
        hColorScheme(
            light: Color(hexString: "121212"),
            dark: Color(hexString: "FAFAFA")
        )
    }

    public static var secondary: some hColor {
        hColorScheme(
            Color(hexString: "727272")
        )
    }

    public static var tertiary: some hColor {
        hColorScheme(
            Color(hexString: "B4B4B4")
        )
    }

    public static var disabled: some hColor {
        hColorScheme(
            Color(hexString: "CFCFCF")
        )
    }

    public static var active: some hColor {
        hGreenColorNew.green800
    }

    public static var warning: some hColor {
        hAmberColorNew.amber600
    }
}

public struct hGreenColorNew {
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

    public static var green800: some hColor {
        hColorScheme(
            Color(hexString: "4C6440")
        )
    }

    public static var greenSemantic: some hColor {
        hColorScheme(
            Color(hexString: "E9FFC8")
        )
    }
}

public struct hYellowColorNew {
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

public struct hAmberColorNew {
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
}

public struct hRedColorNew {
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
}

public struct hPinkColorNew {
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

public struct hPurpleColorNew {
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

public struct hBlueColorNew {
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
}

public struct hTealColorNew {

}

public struct hBorderColorNew {
    public static var opaqueOne: some hColor {
        hColorScheme(
            Color(hexString: "EAEAEA")
        )
    }

    public static var opaqueTwo: some hColor {
        hColorScheme(
            Color(hexString: "E0E0E0")
        )
    }

    public static var opaqueThree: some hColor {
        hColorScheme(
            Color(hexString: "727272")
        )
    }

    public static var opaqueFour: some hColor {
        hColorScheme(
            Color(hexString: "505050")
        )
    }

    public static var translucentOne: some hColor {
        hColorScheme(
            Color(hexString: "E0E0E0").opacity(0.6)
        )
    }

    public static var translucentTwo: some hColor {
        hColorScheme(
            Color(hexString: "CFCFCF").opacity(0.6)
        )
    }

    public static var translucentThree: some hColor {
        hColorScheme(
            Color(hexString: "505050").opacity(0.8)
        )
    }

    public static var translucentFour: some hColor {
        hColorScheme(
            Color(hexString: "303030").opacity(0.84)
        )
    }

    public static var active: some hColor {
        hGreenColorNew.green300
    }

    public static var warning: some hColor {
        hAmberColorNew.amber300
    }
}

public struct hFillColorNew {
    public static var opaqueOne: some hColor {
        hColorScheme(
            Color(hexString: "F0F0F0")
        )
    }

    public static var opaqueTwo: some hColor {
        hColorScheme(
            Color(hexString: "E0E0E0")
        )
    }

    public static var opaqueThree: some hColor {
        hColorScheme(
            Color(hexString: "CFCFCF")
        )
    }

    public static var translucentOne: some hColor {
        hColorScheme(
            Color(hexString: "EAEAEA").opacity(0.6)
        )
    }

    public static var translucentTwo: some hColor {
        hColorScheme(
            Color(hexString: "CFCFCF").opacity(0.7)
        )
    }

    public static var translucentThree: some hColor {
        hColorScheme(
            Color(hexString: "B4B4B4").opacity(0.6)
        )
    }
}

public struct hHighlightColorNew {
    public static var blueFillOne: some hColor {
        hColorScheme(
            Color(hexString: "E0F0F9").opacity(0.6)
        )
    }

    public static var blueFillTwo: some hColor {
        hColorScheme(
            Color(hexString: "CFE5F2").opacity(0.6)
        )
    }

    public static var purpleFillOne: some hColor {
        hColorScheme(
            Color(hexString: "EBE3F6").opacity(0.6)
        )
    }

    public static var purpleFillTwo: some hColor {
        hColorScheme(
            Color(hexString: "DDD5E9").opacity(0.6)
        )
    }

    public static var yellowFillOne: some hColor {
        hColorScheme(
            Color(hexString: "F6F1C0").opacity(0.6)
        )
    }

    public static var yellowFillTwo: some hColor {
        hColorScheme(
            Color(hexString: "EBE5AD").opacity(0.6)
        )
    }

    public static var tealFillOne: some hColor {
        hColorScheme(
            Color(hexString: "DBF5F3").opacity(0.6)
        )
    }

    public static var tealFillTwo: some hColor {
        hColorScheme(
            Color(hexString: "D4EFED").opacity(0.6)
        )
    }

    public static var pinkFillOne: some hColor {
        hColorScheme(
            Color(hexString: "FBE7F3").opacity(0.6)
        )
    }

    public static var pinkFillTwo: some hColor {
        hColorScheme(
            Color(hexString: "F2D9E8").opacity(0.6)
        )
    }
}

public struct hSignalColorNew {
    public static var greenFillOne: some hColor {
        hColorScheme(
            Color(hexString: "E2F6C6").opacity(0.6)
        )
    }

    public static var greenFillTwo: some hColor {
        hColorScheme(
            Color(hexString: "D1E4B6").opacity(0.6)
        )
    }

    public static var greenElement: some hColor {
        hColorScheme(
            Color(hexString: "24CC5C").opacity(0.6)
        )
    }

    public static var greenText: some hColor {
        hColorScheme(
            Color(hexString: "4C6440").opacity(0.6)
        )
    }

    public static var amberFillOne: some hColor {
        hColorScheme(
            Color(hexString: "FBEDC5").opacity(0.6)
        )
    }

    public static var amberFillTwo: some hColor {
        hColorScheme(
            Color(hexString: "F5E0A3").opacity(0.6)
        )
    }

    public static var amberElement: some hColor {
        hColorScheme(
            Color(hexString: "FFBF00").opacity(0.6)
        )
    }

    public static var amberText: some hColor {
        hColorScheme(
            Color(hexString: "8A4C0F").opacity(0.6)
        )
    }

    public static var redFillOne: some hColor {
        hColorScheme(
            Color(hexString: "FDE8E5").opacity(0.6)
        )
    }

    public static var redFillTwo: some hColor {
        hColorScheme(
            Color(hexString: "F2CFCA").opacity(0.6)
        )
    }

    public static var redElement: some hColor {
        hColorScheme(
            Color(hexString: "FF513A").opacity(0.6)
        )
    }

    public static var redText: some hColor {
        hColorScheme(
            Color(hexString: "AC2F1E").opacity(0.6)
        )
    }
}
