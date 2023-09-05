import UIKit
import hCore

extension Localization.Locale {
    public var icon: UIImage {
        switch self {
        case .sv_SE:
            return hCoreUIAssets.flagSE.image
        case .nb_NO:
            return hCoreUIAssets.flagNO.image
        case .da_DK:
            return hCoreUIAssets.flagDK.image
        case .fr_FR:
            return hCoreUIAssets.flagFR.image
        case .en_SE, .en_NO, .en_DK, .en_FR:
            return hCoreUIAssets.flagUK.image
        }
    }
}
