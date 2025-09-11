import Foundation
import SwiftUI
import hCoreUI

@MainActor
extension Message {
    @hColorBuilder
    func bgColor(conversationStatus: ConversationStatus, type: MessageType) -> some hColor {
        if case .failed = status {
            if case .automaticSuggestions = type {
                hBackgroundColor.clear
            } else {
                hSignalColor.Red.highlight
            }
        } else {
            switch type {
            case .action, .automaticSuggestions:
                hBackgroundColor.clear
            default:
                switch self.sender {
                case .hedvig, .automatic:
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
    }

    @hColorBuilder
    var textColor: some hColor {
        switch self.sender {
        case .hedvig, .automatic:
            hTextColor.Opaque.primary
        case .member:
            hTextColor.Opaque.primary.colorFor(.light, .elevated)
        }
    }

    var horizontalPadding: CGFloat {
        switch type {
        case .text, .deepLink:
            return .padding16
        default:
            return 0
        }
    }

    var verticalPadding: CGFloat {
        switch type {
        case .text, .deepLink:
            return .padding12
        default:
            return 0
        }
    }
}

struct MessageViewBackground: ViewModifier {
    let message: Message
    let conversationStatus: ConversationStatus

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, message.horizontalPadding)
            .padding(.vertical, message.verticalPadding)
            .background(message.bgColor(conversationStatus: conversationStatus, type: message.type))
            .foregroundColor(message.textColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
