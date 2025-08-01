import hCore
import SwiftUI

public extension Localization.Locale {
    var icon: Image {
        switch self {
        case .sv_SE:
            return hCoreUIAssets.flagSE.view
        case .en_SE:
            return hCoreUIAssets.flagUK.view
        }
    }
}
