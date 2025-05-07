import SwiftUI

public enum hButtonConfigurationType: Sendable, CaseIterable {
    case primary
    case primaryAlt
    case secondary
    case secondaryAlt
    case ghost
    case alert

    @MainActor
    var hButtonColorSet: hButtonColor {
        switch self {
        case .primary: return Primary()
        case .primaryAlt: return PrimaryAlt()
        case .secondary: return Secondary()
        case .secondaryAlt: return SecondaryAlt()
        case .ghost: return Ghost()
        case .alert: fatalError("Alert type should not be passed to regularBackgroundColor.")
        }
    }

    // TODO: IS THIS USED?
    func shouldUseDark(for schema: ColorScheme) -> Bool {
        switch schema {
        case .dark:
            switch self {
            case .primary, .primaryAlt:
                return false
            case .secondary, .secondaryAlt, .ghost, .alert:
                return true
            }
        case .light:
            switch self {
            case .primary:
                return false
            default:
                return true
            }
        @unknown default:
            return false
        }
    }
}
