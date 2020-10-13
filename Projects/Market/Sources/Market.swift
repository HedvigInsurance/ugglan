import Foundation
import hCore
import UIKit

public enum Market: CaseIterable {
    case sweden, norway, denmark

    var id: String {
        switch self {
        case .norway:
            return "no"
        case .sweden:
            return "se"
        case .denmark:
            return "dk"
        }
    }

    var title: String {
        switch self {
        case .norway:
            return "Norge"
        case .sweden:
            return "Sverige"
        case .denmark:
            return "Danmark"
        }
    }

    var icon: UIImage {
        switch self {
        case .norway:
            return Asset.flagNO.image
        case .sweden:
            return Asset.flagSE.image
        case .denmark:
            return Asset.flagDK.image
        }
    }

    var languages: [Localization.Locale] {
        switch self {
        case .norway:
            return [.nb_NO, .en_NO]
        case .sweden:
            return [.sv_SE, .en_SE]
        case .denmark:
            return [.da_DK, .en_DK]
        }
    }

    var enabled: Bool {
        switch self {
        case .norway, .sweden:
            return true
        case .denmark:
            return ApplicationState.getTargetEnvironment() == .staging
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

        return Localization.Locale(
            rawValue: bestMatchedLanguage.replacingOccurrences(of: "-", with: "_")
        ) ?? firstLanguage
    }
}
