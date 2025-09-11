import Foundation
import SwiftUI
import hCoreUI

struct ActionView: View {
    let action: ActionMessage
    let automaticSuggestion: AutomaticSuggestions?
    let isAutomatedMessage: Bool
    let message: Message
    let showAsFailed: Bool
    @ObservedObject var vm: ChatScreenViewModel

    init(
        action: ActionMessage,
        automaticSuggestion: AutomaticSuggestions? = nil,
        message: Message,
        vm: ChatScreenViewModel,
        isAutomatedMessage: Bool? = false,
        showAsFailed: Bool? = true
    ) {
        self.action = action
        self.automaticSuggestion = automaticSuggestion
        self.message = message
        self.vm = vm
        self.isAutomatedMessage = isAutomatedMessage ?? false
        self.showAsFailed = showAsFailed ?? true
    }

    var body: some View {
        HStack(alignment: .top) {
            if isAutomatedMessage {
                Image(systemName: "lightbulb")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 36)
                    .padding(.trailing, 12)
                    .padding(.leading, 4)
                    .padding(.top, 8)
                    .foregroundColor(hGrayscaleOpaqueColor.greyScale500)

                VStack(spacing: .padding16) {
                    if let text = action.text {
                        hText(text, style: .body1)
                            .foregroundColor(hTextColor.Opaque.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if let automaticSuggestion {
                        hButton(
                            .small,
                            .ghost,
                            content: .init(title: action.buttonTitle)
                        ) {
                            Task {
                                await vm.escalateMessage(message: message, automaticSuggestion: automaticSuggestion)
                            }
                        }
                        .hButtonTakeFullWidth(true)
                    } else {
                        hButton(
                            .medium,
                            .secondary,
                            content: .init(
                                title: action.buttonTitle,
                                buttonImage: isAutomatedMessage
                                    ? .init(image: hCoreUIAssets.chevronRight.view, alignment: .trailing) : nil
                            )
                        ) {
                            NotificationCenter.default.post(name: .openDeepLink, object: action.url)
                        }
                        .hButtonTakeFullWidth(true)
                    }
                }
            }
        }
    }
}

//#Preview(body: {
//    Dependencies.shared.add(module: Module { () -> ConversationClient in ConversationsDemoClient() })
//    let service = ConversationService(conversationId: "conversationId")
//
//    let url = URL(string: "https://hedvig.com")
//
//    return MessageView(
//        message: .init(
//            localId: nil,
//            remoteId: nil,
//            sender: .automatic,
//            sentAt: Date(),
//            type: .automaticSuggestions(
//                suggestions: AutomaticSuggestions(
//                    suggestions: [
//                        .init(
//                            url: url!,
//                            text:
//                                "Congratulations on the new apartment! To move your insurance, just follow this link:",
//                            buttonTitle: "Get a new price"
//                        )
//
//                    ],
//                    escalationReference: "escalationReference"
//                )
//            ),
//            status: .sent
//        ),
//        conversationStatus: .open,
//        vm: .init(chatService: service),
//        height: 300,
//        width: 300,
//        showRetryOptions: true
//    )
//})
