import Foundation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public enum Market: String, CaseIterable, Codable {
    case sweden = "SE"
    case norway = "NO"
    case denmark = "DK"
    case france = "FR"

    var id: String {
        switch self {
        case .norway: return "no"
        case .sweden: return "se"
        case .denmark: return "dk"
        case .france: return "fr"
        }
    }

    public var title: String {
        switch self {
        case .norway: return "Norge"
        case .sweden: return "Sverige"
        case .denmark: return "Danmark"
        case .france: return "La France"
        }
    }

    public var icon: UIImage {
        switch self {
        case .norway: return hCoreUIAssets.flagNO.image
        case .sweden: return hCoreUIAssets.flagSE.image
        case .denmark: return hCoreUIAssets.flagDK.image
        case .france: return hCoreUIAssets.flagFR.image
        }
    }

    var languages: [Localization.Locale] {
        switch self {
        case .norway: return [.nb_NO, .en_NO]
        case .sweden: return [.sv_SE, .en_SE]
        case .denmark: return [.da_DK, .en_DK]
        case .france: return [.fr_FR, .en_FR]
        }
    }

    var preferredLanguage: Localization.Locale {
        guard let firstLanguage = languages.first else { return .sv_SE }

        guard
            let bestMatchedLanguage = Bundle.preferredLocalizations(from: languages.map { $0.lprojCode })
                .first
        else { return firstLanguage }

        return Localization.Locale(rawValue: bestMatchedLanguage.replacingOccurrences(of: "-", with: "_"))
            ?? firstLanguage
    }

    static func fromLocalization(_ market: Localization.Locale.Market) -> Self {
        switch market {
        case .dk: return .denmark
        case .se: return .sweden
        case .no: return .norway
        case .fr: return .france
        }
    }
}
