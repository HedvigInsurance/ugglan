import Foundation
import SwiftUI
import hCore

public enum ToolbarOptionType: Int, Hashable, Codable, Equatable, Sendable {
    case newOffer
    case newOfferNotification
    case firstVet
    case chat
    case chatNotification
    case travelCertificate
    case insuranceEvidence

    @MainActor
    private static var animateOffer = true

    @MainActor
    var image: UIImage {
        switch self {
        case .newOffer, .newOfferNotification:
            return hCoreUIAssets.campaignQuickNav.image
        case .firstVet:
            return hCoreUIAssets.firstVetQuickNav.image
        case .chat, .chatNotification:
            return hCoreUIAssets.inbox.image
        case .travelCertificate, .insuranceEvidence:
            return hCoreUIAssets.infoOutlined.image
        }
    }

    var displayName: String {
        switch self {
        case .newOffer:
            return L10n.InsuranceTab.CrossSells.title
        case .firstVet:
            return L10n.hcQuickActionsFirstvetTitle
        case .chat:
            return L10n.CrossSell.Info.faqChatButton
        case .chatNotification:
            return L10n.Toast.newMessage
        case .travelCertificate, .insuranceEvidence:
            return L10n.InsuranceEvidence.documentTitle
        case .newOfferNotification:
            return L10n.hcQuickActionsFirstvetTitle
        }
    }

    var tooltipId: String {
        switch self {
        case .newOffer:
            return "newOfferHint"
        case .newOfferNotification:
            return "newOfferHintNotification"
        case .firstVet:
            return "firstVetHint"
        case .chat:
            return "chatHint"
        case .chatNotification:
            return "chatHintNotification"
        case .travelCertificate:
            return "travelCertHint"
        case .insuranceEvidence:
            return "insuranceEvidenceHint"
        }
    }

    var identifiableId: String {
        tooltipId
    }

    var textToShow: String? {
        switch self {
        case .newOffer:
            return nil
        case .firstVet:
            return nil
        case .newOfferNotification:
            return L10n.Toast.newOffer
        case .chat:
            return L10n.HomeTab.chatHintText
        case .chatNotification:
            return L10n.Toast.newMessage
        case .travelCertificate, .insuranceEvidence:
            return L10n.Toast.readMore
        }
    }

    var showAsTooltip: Bool {
        switch self {
        case .firstVet, .chat, .newOffer:
            return false
        default:
            return true
        }
    }

    var showBadge: Bool {
        switch self {
        case .chatNotification, .newOfferNotification:
            return true
        default:
            return false
        }
    }

    var timeIntervalForShowingAgain: TimeInterval? {
        switch self {
        case .chat:
            return .days(numberOfDays: 30)
        case .chatNotification:
            return 30
        case .travelCertificate, .insuranceEvidence:
            return 60
        case .newOfferNotification:
            return 60 * 10  // 10 minutes
        default:
            return nil
        }
    }

    var delay: TimeInterval {
        switch self {
        case .chat:
            return 1.5
        case .chatNotification, .travelCertificate, .insuranceEvidence:
            return 0.5
        default:
            return 0
        }
    }

    func shouldShowTooltip(for timeInterval: TimeInterval) -> Bool {
        guard showAsTooltip else {
            return false
        }
        switch self {
        case .chat:
            if let pastDate = UserDefaults.standard.value(forKey: userDefaultsKey) as? Date {
                let timeIntervalSincePast = abs(
                    pastDate.timeIntervalSince(Date())
                )

                if timeIntervalSincePast > timeInterval {
                    return true
                }

                return false
            }
            return true
        case .chatNotification:
            if let pastDate = UserDefaults.standard.value(forKey: userDefaultsKey) as? Date {
                let timeIntervalSincePast = abs(
                    pastDate.timeIntervalSince(Date())
                )

                if timeIntervalSincePast > timeInterval {
                    return true
                }
                return false
            }
            return true
        case .travelCertificate, .insuranceEvidence:
            if let pastDate = UserDefaults.standard.value(forKey: userDefaultsKey) as? Date {
                let timeIntervalSincePast = abs(
                    pastDate.timeIntervalSince(Date())
                )

                if timeIntervalSincePast > timeInterval {
                    return true
                }
                return false
            }
            return true
        case .newOfferNotification, .newOffer:
            if let pastDate = UserDefaults.standard.value(forKey: userDefaultsKey) as? Date {
                let timeIntervalSincePast = abs(
                    pastDate.timeIntervalSince(Date())
                )

                if timeIntervalSincePast > timeInterval {
                    return true
                }
                return false
            }
            return true
        default:
            return false
        }
    }

    var imageSize: CGFloat {
        switch self {
        case .travelCertificate, .insuranceEvidence:
            return 24
        default:
            return 40
        }
    }

    @MainActor
    var shouldAnimate: Bool {
        switch self {
        case .newOfferNotification, .newOffer:
            Task {
                try await Task.sleep(seconds: 3)
                ToolbarOptionType.animateOffer = false
            }
            return ToolbarOptionType.animateOffer
        default:
            return false
        }
    }

    @hColorBuilder @MainActor
    var tooltipBackgroundColor: some hColor {
        switch self {
        case .travelCertificate, .insuranceEvidence:
            hFillColor.Opaque.primary
        case .newOfferNotification:
            hSignalColor.Green.fill
        default:
            hFillColor.Opaque.secondary
        }
    }

    @hColorBuilder @MainActor
    var tooltipTextColor: some hColor {
        switch self {
        case .newOfferNotification:
            hSignalColor.Green.text
        default:
            hTextColor.Opaque.negative
        }
    }

    var shadowColor: Color {
        switch self {
        case .travelCertificate, .insuranceEvidence:
            return Color.clear
        default:
            return .black.opacity(0.15)
        }
    }

    func onShow() {
        switch self {
        case .chat:
            UserDefaults.standard.setValue(Date(), forKey: userDefaultsKey)
        case .chatNotification:
            UserDefaults.standard.setValue(Date(), forKey: userDefaultsKey)
        case .travelCertificate, .insuranceEvidence:
            UserDefaults.standard.setValue(Date(), forKey: userDefaultsKey)
        case .newOfferNotification, .newOffer:
            UserDefaults.standard.setValue(Date(), forKey: userDefaultsKey)
        default:
            break
        }
    }

    var userDefaultsKey: String {
        "tooltip_\(tooltipId)_past_date"
    }

    public func resetTooltipDisplayState() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
