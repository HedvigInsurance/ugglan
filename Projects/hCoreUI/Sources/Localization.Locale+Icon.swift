import SwiftUI
import hCore

extension Localization.Locale {
    public var icon: Image {
        switch self {
        case .sv_SE:
            return hCoreUIAssets.flagSE.view
        case .en_SE:
            return hCoreUIAssets.flagUK.view
        }
    }
}
