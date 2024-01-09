import Foundation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public enum Market: String, CaseIterable, Codable {
    case sweden = "SE"
    case norway = "NO"
    case denmark = "DK"

    var id: String {
        switch self {
        case .norway: return "no"
        case .sweden: return "se"
        case .denmark: return "dk"
        }
    }

    public var title: String {
        switch self {
        case .norway: return L10n.marketNorway
        case .sweden: return L10n.marketSweden
        case .denmark: return L10n.marketDenmark
        }
    }

    public var icon: UIImage {
        switch self {
        case .norway: return hCoreUIAssets.flagNO.image
        case .sweden: return hCoreUIAssets.flagSE.image
        case .denmark: return hCoreUIAssets.flagDK.image
        }
    }

    static var activatedMarkets: [Market] {
        var activatedMarkets: [Market] = [.denmark, .sweden, .norway]
        return activatedMarkets
    }

    var languages: [Localization.Locale] {
        switch self {
        case .norway: return [.nb_NO, .en_NO]
        case .sweden: return [.sv_SE, .en_SE]
        case .denmark: return [.da_DK, .en_DK]
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
        }
    }

    var showGetQuote: Bool {
        switch self {
        case .sweden:
            return true
        case .norway, .denmark:
            return false
        }
    }
}
