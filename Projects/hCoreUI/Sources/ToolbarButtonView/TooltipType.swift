import Foundation
import SwiftUI
import hCore

public enum ToolbarOptionType: Hashable, Codable, Equatable, Sendable {
    case crossSell(hasNewOffer: Bool)
    case firstVet
    case chat(hasUnread: Bool)
    case travelCertificate
    case insuranceEvidence

    @MainActor
    private static var animateOffer = true

    @MainActor
    var image: Image {
        switch self {
        case .crossSell:
            if isLiquidGlassEnabled {
                return hCoreUIAssets.campaign.view
            } else {
                return hCoreUIAssets.campaignQuickNav.view
            }
        case .firstVet:
            if isLiquidGlassEnabled {
                return hCoreUIAssets.firstVet.view
            } else {
                return hCoreUIAssets.firstVetQuickNav.view
            }
        case .chat:
            if isLiquidGlassEnabled {
                return hCoreUIAssets.envelope.view
            } else {
                return hCoreUIAssets.inbox.view
            }
        case .travelCertificate, .insuranceEvidence:
            return hCoreUIAssets.infoOutlined.view
        }
    }
    var priority: Int {
        switch self {
        case .crossSell:
            return 1
        case .firstVet:
            return 0
        case .chat:
            return 2
        case .travelCertificate, .insuranceEvidence:
            return 3
        }
    }

    var accessibilityDisplayName: String {
        switch self {
        case .crossSell:
            return L10n.InsuranceTab.CrossSells.title
        case .firstVet:
            return L10n.hcQuickActionsFirstvetTitle
        case .chat:
            return L10n.chatConversationInbox
        case .travelCertificate, .insuranceEvidence:
            return L10n.InsuranceEvidence.documentTitle
        }
    }

    @MainActor
    var displayName: String? {
        switch self {
        case .chat:
            if isLiquidGlassEnabled {
                return L10n.chatConversationInbox
            }
            return nil
        default:
            return nil
        }
    }

    var showBadge: Bool {
        switch self {
        case let .crossSell(hasNewOffser):
            return hasNewOffser
        case let .chat(hasUnread):
            return hasUnread
        default:
            return false
        }
    }

    var tooltipId: String {
        switch self {
        case .crossSell:
            return "newOfferHint"
        case .firstVet:
            return "firstVetHint"
        case .chat:
            return "chatHint"
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
        case .crossSell:
            return L10n.Toast.newOffer
        case .firstVet:
            return nil
        case .chat:
            return L10n.Toast.newMessage
        case .travelCertificate, .insuranceEvidence:
            return L10n.Toast.readMore
        }
    }

    var timeIntervalForShowingAgain: TimeInterval? {
        switch self {
        case .chat:
            return 30
        case .travelCertificate, .insuranceEvidence:
            return 60
        case .crossSell:
            return 60 * 10  // 10 minutes
        default:
            return nil
        }
    }

    var delay: TimeInterval {
        switch self {
        case .chat:
            return 1.5
        case .travelCertificate, .insuranceEvidence:
            return 0.5
        default:
            return 0
        }
    }

    func shouldShowTooltip(for timeInterval: TimeInterval) -> Bool {
        switch self {
        case let .chat(hasUnread):
            if !hasUnread { return false }
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
        case let .crossSell(hasNewOffer):
            if !hasNewOffer { return false }
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
        default:
            return false
        }
    }

    @MainActor
    var imageSize: CGFloat {
        switch self {
        case .travelCertificate, .insuranceEvidence:
            return 24
        case .crossSell:
            if isLiquidGlassEnabled {
                return 20
            }
        case .firstVet, .chat:
            if isLiquidGlassEnabled {
                return 17
            }
        }
        return 40
    }

    @MainActor
    var offsetForToolTip: CGFloat {
        switch self {
        case .travelCertificate, .insuranceEvidence:
            return 40
        case .crossSell, .firstVet, .chat:
            return 40
        }
    }

    @MainActor
    @hColorBuilder
    var imageTintColor: some hColor {
        switch self {
        case .crossSell:
            hSignalColor.Green.element
        case .firstVet:
            hSignalColor.Blue.firstVet
        default:
            hFillColor.Opaque.primary
        }
    }

    @MainActor
    var navBarItemBackgroundColor: UIColor? {
        switch self {
        case .travelCertificate, .insuranceEvidence:
            return hFillColor.Opaque.primary.colorFor(.dark, .base).color.uiColor()
        case .crossSell:
            return hSignalColor.Green.fill.colorFor(.dark, .base).color.uiColor()
        case .firstVet:
            return hSignalColor.Blue.firstVet.colorFor(.dark, .base).color.uiColor()
        case .chat:
            return hSignalColor.Grey.element.colorFor(.dark, .base).color.uiColor()
        }
    }

    @MainActor
    var shouldAnimate: Bool {
        switch self {
        case .crossSell:
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
        case .crossSell:
            hSignalColor.Green.fill
        default:
            hFillColor.Opaque.secondary
        }
    }

    @hColorBuilder @MainActor
    var tooltipTextColor: some hColor {
        switch self {
        case .crossSell:
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
        case .travelCertificate, .insuranceEvidence:
            UserDefaults.standard.setValue(Date(), forKey: userDefaultsKey)
        case .crossSell:
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
