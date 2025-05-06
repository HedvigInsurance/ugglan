import SwiftUI
import hCore

extension Localization.Locale {
    public var icon: UIImage {
        switch self {
        case .sv_SE:
            return hCoreUIAssets.flagSE.image
        case .en_SE:
            return hCoreUIAssets.flagUK.image
        }
    }
}
