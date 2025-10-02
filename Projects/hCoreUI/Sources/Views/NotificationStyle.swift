import SwiftUI
import UIKit

@MainActor
public enum NotificationType {
    case info
    case attention
    case error
    case campaign
    case neutral
    case escalation

    var image: Image {
        switch self {
        case .info:
            return hCoreUIAssets.infoFilled.view
        case .attention:
            return hCoreUIAssets.warningTriangleFilled.view
        case .error:
            return hCoreUIAssets.warningTriangleFilled.view
        case .campaign:
            return hCoreUIAssets.campaignSmall.view
        case .neutral:
            return hCoreUIAssets.infoFilled.view
        case .escalation:
            return hCoreUIAssets.infoFilled.view
        }
    }

    @hColorBuilder
    public var titleColor: some hColor {
        switch self {
        case .neutral:
            hTextColor.Translucent.primary
        default:
            hTextColor.Translucent.primary.colorFor(.light, .base)
        }
    }

    @hColorBuilder
    public var textColor: some hColor {
        switch self {
        case .info:
            hSignalColor.Blue.text
        case .attention:
            hSignalColor.Amber.text
        case .error:
            hSignalColor.Red.text
        case .campaign:
            hSignalColor.Green.text
        case .neutral:
            hTextColor.Opaque.secondary
        case .escalation:
            hTextColor.Translucent.secondary.colorFor(.light, .base)
        }
    }

    @hColorBuilder
    public var imageColor: some hColor {
        switch self {
        case .info:
            hSignalColor.Blue.element
        case .attention:
            hSignalColor.Amber.element
        case .error:
            hSignalColor.Red.element
        case .campaign:
            hSignalColor.Green.element
        case .neutral:
            hFillColor.Opaque.secondary
        case .escalation:
            hPerilColor.Purple.fillThree
        }
    }

    @hColorBuilder
    public var toastImageColor: some hColor {
        switch self {
        case .info:
            hSignalColor.Green.element
        default:
            imageColor
        }
    }
}

struct NotificationStyle: ViewModifier {
    let type: NotificationType
    @Environment(\.hInfoCardLayoutStyle) var layoutStyle

    func body(content: Content) -> some View {
        switch layoutStyle {
        case .bannerStyle:
            content
                .background(
                    Rectangle()
                        .fill(backgroundColor)
                        .overlay(
                            Rectangle()
                                .strokeBorder(hBorderColor.primary, lineWidth: 0.5)
                        )
                )
        case .defaultStyle:
            switch type {
            case .neutral:
                content
                    .background(backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                    .overlay(
                        RoundedRectangle(cornerRadius: .cornerRadiusL)
                            .strokeBorder(hBorderColor.primary, lineWidth: 1)
                    )
            case .escalation:
                content
                    .background(backgroundColor)
                    .withGradientBorder(shape: RoundedRectangle(cornerRadius: .cornerRadiusL))
            default:
                content
                    .background(backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
            }
        }
    }

    @hColorBuilder
    var backgroundColor: some hColor {
        switch type {
        case .info:
            hSignalColor.Blue.fill
        case .attention:
            hSignalColor.Amber.fill
        case .error:
            hSignalColor.Red.fill
        case .campaign:
            hSignalColor.Green.fill
        case .neutral:
            hFillColor.Opaque.negative
        case .escalation:
            hHighlightColor.Purple.fillOne
        }
    }
}
