import hCore
import hCoreUI

enum CoInsuredFieldType {
    case empty
    case localEdit
    case delete

    @MainActor
    var icon: ImageAsset? {
        switch self {
        case .empty:
            return hCoreUIAssets.plusSmall
        case .delete:
            return hCoreUIAssets.closeSmall
        case .localEdit:
            return nil
        }
    }

    @hColorBuilder @MainActor
    var iconColor: some hColor {
        switch self {
        case .delete:
            hTextColor.Opaque.secondary
        default:
            hTextColor.Opaque.primary
        }
    }

    var text: String? {
        switch self {
        case .empty:
            return L10n.generalAddInfoButton
        case .delete:
            return nil
        case .localEdit:
            return L10n.Claims.Edit.Screen.title
        }
    }

    var action: CoInsuredAction {
        switch self {
        case .empty:
            return .add
        case .localEdit:
            return .edit
        case .delete:
            return .delete
        }
    }

    var title: String {
        switch self {
        case .empty:
            return L10n.contractAddConisuredInfo
        case .localEdit:
            return L10n.contractAddConisuredInfo
        case .delete:
            return L10n.contractRemoveCoinsuredConfirmation
        }
    }

    var accessibilityValue: String {
        switch self {
        case .empty:
            return L10n.voiceoverDoubleClickTo + L10n.voiceoverAddInformation
        case .localEdit:
            return L10n.voiceoverDoubleClickTo + L10n.voiceoverEdit
        case .delete:
            return L10n.voiceoverDoubleClickTo + L10n.voiceoverRemove
        }
    }
}
