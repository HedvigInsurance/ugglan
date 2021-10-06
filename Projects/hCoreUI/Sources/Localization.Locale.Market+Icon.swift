import Foundation
import UIKit
import hCore

extension Localization.Locale.Market {
    public var icon: UIImage {
        switch self {
        case .no: return hCoreUIAssets.flagNO.image
        case .se: return hCoreUIAssets.flagSE.image
        case .dk: return hCoreUIAssets.flagDK.image
        }
    }
}
