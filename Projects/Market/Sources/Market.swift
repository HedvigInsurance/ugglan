import Foundation
import hCore
import UIKit

public enum Market: CaseIterable {
    case norway, sweden

    var id: String {
        switch self {
        case .norway:
            return "no"
        case .sweden:
            return "se"
        }
    }

    var title: String {
        switch self {
        case .norway:
            return "Norge"
        case .sweden:
            return "Sverige"
        }
    }

    var icon: UIImage {
        switch self {
        case .norway:
            return Asset.flagNO.image
        case .sweden:
            return Asset.flagSE.image
        }
    }

    var languages: [Localization.Locale] {
        switch self {
        case .norway:
            return [.nb_NO, .en_NO]
        case .sweden:
            return [.sv_SE, .en_SE]
        }
    }

    var preferredLanguage: Localization.Locale {
        guard let firstLanguage = languages.first else {
            return .sv_SE
        }

        guard let bestMatchedLanguage = Bundle.preferredLocalizations(
            from: languages.map { $0.lprojCode }
        ).first else {
            return firstLanguage
        }

        return Localization.Locale(rawValue: bestMatchedLanguage) ?? firstLanguage
    }
}
