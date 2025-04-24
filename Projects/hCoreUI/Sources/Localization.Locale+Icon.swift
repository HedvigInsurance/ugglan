import SwiftUI
import hCore

extension Localization.Locale {
    public var icon: UIImage {
        switch self {
        case .sv_SE:
            return hCoreUIAssets.flagSE.image
        case .en_SE, .en_NO, .en_DK:
            return hCoreUIAssets.flagUK.image
        }
    }
}
