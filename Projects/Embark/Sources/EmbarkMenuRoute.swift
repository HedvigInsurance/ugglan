import hCore
import hCoreUI
import UIKit

public enum EmbarkMenuRoute: CaseIterable {
    case appInformation
    case appSettings
    case login
    case restart

    var title: String {
        switch self {
        case .appInformation:
            return L10n.aboutScreenTitle
        case .appSettings:
            return L10n.Profile.AppSettingsSection.title
        case .login:
            return L10n.settingsLoginRow
        case .restart:
            return L10n.embarkRestartButton
        }
    }

    var style: MenuStyle {
        switch self {
        case .restart:
            return .destructive
        case .appInformation, .appSettings, .login:
            return .default
        }
    }

    var image: UIImage {
        switch self {
        case .appInformation:
            return hCoreUIAssets.infoLarge.image
        case .appSettings:
            return hCoreUIAssets.settingsIcon.image
        case .restart:
            return hCoreUIAssets.restart.image
        case .login:
            return hCoreUIAssets.memberCard.image
        }
    }
}
