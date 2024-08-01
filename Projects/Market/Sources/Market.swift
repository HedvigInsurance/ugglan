import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public enum Market: String, CaseIterable, Codable {
    case sweden = "SE"

    var id: String {
        switch self {
        case .sweden: return "se"
        }
    }

    public var title: String {
        switch self {
        case .sweden: return L10n.marketSweden
        }
    }

    public var icon: UIImage {
        switch self {
        case .sweden: return hCoreUIAssets.flagSE.image
        }
    }

    static var activatedMarkets: [Market] {
        let activatedMarkets: [Market] = [.sweden]
        return activatedMarkets
    }

    var languages: [Localization.Locale] {
        switch self {
        case .sweden: return [.sv_SE, .en_SE]
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
        case .se: return .sweden
        }
    }

    var showGetQuote: Bool {
        switch self {
        case .sweden:
            return true
        }
    }
}
