import SwiftUI
import UIKit

public enum NotificationType {
    case info
    case attention
    case error
    case campaign

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
        }
    }
}

struct NotificationStyle: ViewModifier {
    let type: NotificationType
    @Environment(\.hInfoCardLayoutStyle) var layoutStyle

    func body(content: Content) -> some View {
        switch layoutStyle {
        case .rectange:
            content
                .background(
                    Rectangle()
                        .fill(backgroundColor)
                        .overlay(
                            Rectangle()
                                .strokeBorder(hBorderColor.primary, lineWidth: 0.5)
                        )
                )
        case .roundedRectangle:
            content
                .background(
                    Squircle.default()
                        .fill(backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: .cornerRadiusL)
                                .strokeBorder(hBorderColor.primary, lineWidth: 0.5)
                        )
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
        }
    }
}
