import Foundation
import hCoreUI

@MainActor
extension Message {
    @hColorBuilder
    func bgColor(conversationStatus: ConversationStatus) -> some hColor {
        if case .failed = status {
            hSignalColor.Red.highlight
        } else {
            switch self.sender {
            case .hedvig:
                hSurfaceColor.Opaque.primary
            case .member:
                if conversationStatus == .open {
                    hSignalColor.Blue.fill
                } else {
                    hFillColor.Opaque.disabled
                }
            }
        }
    }

    @hColorBuilder
    var textColor: some hColor {
        switch self.sender {
        case .hedvig:
            hTextColor.Opaque.primary
        case .member:
            hTextColor.Opaque.primary.colorFor(.light, .elevated)
        }
    }

    var horizontalPadding: CGFloat {
        switch type {
        case .text, .deepLink, .action:
            return .padding16
        default:
            return 0
        }
    }
    var verticalPadding: CGFloat {
        switch type {
        case .text, .deepLink, .action:
            return .padding12
        default:
            return 0
        }
    }
}
