import SwiftUI
import UIKit

public enum NotificationType {
    case info
    case attention
    case error
    case campaign
    case neutral

    var image: UIImage {
        switch self {
        case .info:
            return hCoreUIAssets.infoFilled.image
        case .attention:
            return hCoreUIAssets.warningTriangleFilled.image
        case .error:
            return hCoreUIAssets.warningTriangleFilled.image
        case .campaign:
            return hCoreUIAssets.campaignSmall.image
        case .neutral:
            return hCoreUIAssets.infoFilled.image
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
            hTextColor.Translucent.secondary
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
            content
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
                .overlay(
                    RoundedRectangle(cornerRadius: .cornerRadiusL)
                        .strokeBorder(hBorderColor.primary, lineWidth: 0.5)
                )
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
            hSurfaceColor.Opaque.primary
        }
    }
}
