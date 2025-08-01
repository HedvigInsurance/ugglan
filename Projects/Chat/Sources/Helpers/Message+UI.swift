import Foundation
import SwiftUI
import hCoreUI

@MainActor
extension Message {
    @hColorBuilder
    func bgColor(conversationStatus: ConversationStatus) -> some hColor {
        if case .failed = status {
            hSignalColor.Red.highlight
        } else {
            switch sender {
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
        switch sender {
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

struct MessageViewBackground: ViewModifier {
    let message: Message
    let conversationStatus: ConversationStatus

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, message.horizontalPadding)
            .padding(.vertical, message.verticalPadding)
            .background(message.bgColor(conversationStatus: conversationStatus))
            .foregroundColor(message.textColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
