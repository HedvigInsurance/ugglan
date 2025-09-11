import Contracts
import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct MessageView: View {
    let message: Message
    let conversationStatus: ConversationStatus
    @ObservedObject var vm: ChatScreenViewModel
    @State var showRetryOptions = false

    var body: some View {
        HStack(spacing: 0) {
            if case .failed = message.status, message.sender != .automatic {
                messageFailContent
                    .modifier(MessageViewBackground(message: message, conversationStatus: conversationStatus))
            } else {
                messageContent
                    .modifier(MessageViewBackground(message: message, conversationStatus: conversationStatus))
            }
        }
        .frame(
            maxWidth: message.sender.maxWidth,
            alignment: message.sender.alignment
        )
        .padding(.bottom, message.sender == .automatic ? .padding16 : 0)
        .onTapGesture {
            if case .failed = message.status {
                Task {
                    await vm.messageVm.retrySending(message: message)
                }
            }
        }
        .id("MessageView_\(message.id)")
        .modifier(MessageViewConfirmationDialog(message: message, showRetryOptions: $showRetryOptions, vm: vm))
    }

    private var failedView: some View {
        hCoreUIAssets.infoFilled.view
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(hSignalColor.Red.element)
            .padding(.leading, .padding8)
            .onTapGesture {
                showRetryOptions = true
            }
    }

    private func automaticSuggestionView(suggestions: AutomaticSuggestions) -> some View {
        ForEach(suggestions.suggestions, id: \.self) { action in
            if let action {
                VStack(spacing: .padding8) {
                    let suggestionActionView = ActionView(
                        action: action,
                        message: message,
                        vm: vm,
                        isAutomatedMessage: true,
                        showAsFailed: false
                    )

                    if case .failed = message.status {
                        suggestionActionView
                            .padding(.trailing, .padding32)
                    } else {
                        suggestionActionView
                    }
                    if suggestions.escalationReference != nil {
                        HStack(alignment: .top, spacing: 0) {
                            ActionView(
                                action: .init(
                                    url: URL(string: "https://www.hedvig.com")!,
                                    text:
                                        "L10n.Chatbot.TalkToHuman.text",
                                    buttonTitle: "L10n.Chatbot.TalkToHuman.buttonTitle"
                                ),
                                message: message,
                                vm: vm
                            )
                            if case .failed = message.status {
                                failedView
                            }
                        }
                    }
                }
                .environment(\.colorScheme, .light)
            }
        }
    }

    @ViewBuilder
    private var messageContent: some View {
        HStack {
            if case .failed = message.status, message.sender != .automatic {
                hCoreUIAssets.refresh.view
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(hSignalColor.Red.element)
            }
            switch message.type {
            case .text:
                MarkdownView(
                    config: .init(
                        text: message.trimmedText,
                        fontStyle: .body1,
                        color: message.textColor,
                        linkColor: hTextColor.Opaque.primary,
                        linkUnderlineStyle: .thick,
                        maxWidth: 300,
                        onUrlClicked: { url in
                            NotificationCenter.default.post(name: .openDeepLink, object: url)
                        }
                    )
                )
                .hEnvironmentAccessibilityLabel(message.timeStampString)
            case let .file(file):
                ChatFileView(file: file, status: message.status).frame(maxHeight: 200)
                    .accessibilityLabel(accessilityLabel(for: message))
            case let .crossSell(url):
                LinkView(vm: .init(url: url))
                    .accessibilityLabel(L10n.chatSentALink)
            case let .deepLink(url):
                if let type = DeepLink.getType(from: url) {
                    Button {
                        NotificationCenter.default.post(name: .openDeepLink, object: url)
                    } label: {
                        hText(type.getDeeplinkTextFor(contractName: url.contractName))
                            .foregroundColor(hTextColor.Opaque.primary)
                            .multilineTextAlignment(.leading)
                    }
                } else {
                    MarkdownView(
                        config: .init(
                            text: url.absoluteString,
                            fontStyle: .body1,
                            color: message.textColor,
                            linkColor: hTextColor.Opaque.primary,
                            linkUnderlineStyle: .thick,
                            maxWidth: 300,
                            onUrlClicked: { url in
                                NotificationCenter.default.post(name: .openDeepLink, object: url)
                            }
                        )
                    )
                    .hEnvironmentAccessibilityLabel(message.timeStampString)
                }
            case let .otherLink(url):
                LinkView(
                    vm: .init(url: url)
                )
                .accessibilityLabel(accessilityLabel(for: message))
            case let .action(action):
                ActionView(action: action, message: message, vm: vm)
                    .accessibilityLabel(accessilityLabel(for: message))
            case let .automaticSuggestions(suggestions):
                automaticSuggestionView(suggestions: suggestions)
            case .unknown: Text("")
            }
        }
    }

    private func accessilityLabel(for message: Message) -> String {
        var displayString = ""
        switch message.type {
        case .text:
            displayString = message.trimmedText
        case let .file(file):
            displayString = file.mimeType.isImage ? L10n.voiceoverChatImage : L10n.voiceoverChatFile
        case .deepLink, .otherLink:
            displayString = L10n.chatSentALink
        default:
            break
        }
        return message.timeStampString + " " + displayString
    }

    @ViewBuilder
    private var messageFailContent: some View {
        HStack(spacing: 0) {
            hCoreUIAssets.refresh.view
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(hSignalColor.Red.element)
            messageContent
                .environment(\.colorScheme, .light)
            hCoreUIAssets.infoFilled.view
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(hSignalColor.Red.element)
                .padding(.leading, .padding8)
                .onTapGesture {
                    showRetryOptions = true
                }
        }
    }
}

struct MessageViewConfirmationDialog: ViewModifier {
    let message: Message
    @Binding var showRetryOptions: Bool
    @ObservedObject var vm: ChatScreenViewModel

    func body(content: Content) -> some View {
        content
            .confirmationDialog("", isPresented: $showRetryOptions, titleVisibility: .hidden) { [weak vm] in
                Button(L10n.generalRetry) {
                    Task {
                        await vm?.messageVm.retrySending(message: message)
                    }
                }
                Button(L10n.General.remove, role: .destructive) {
                    vm?.messageVm.deleteFailed(message: message)
                }
                Button(L10n.generalCancelButton, role: .cancel) {}
            }
    }
}

@MainActor
extension URL {
    public var contractName: String? {
        guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = urlComponents.queryItems else { return nil }
        let contractIdString = queryItems.first(where: { $0.name == "contractId" })?.value
        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        return contractStore.state.contractForId(contractIdString ?? "")?.currentAgreement?.productVariant.displayName
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ConversationClient in ConversationsDemoClient() })
    let service = ConversationService(conversationId: "conversationId")
    let url = URL(string: "https://hedvig.com")

    return MessageView(
        message: .init(
            id: "messageId",
            sender: .automatic,
            sentAt: Date(),
            type: .automaticSuggestions(
                suggestions: AutomaticSuggestions(
                    suggestions: [
                        .init(
                            url: url!,
                            text:
                                "Congratulations on the new apartment! To move your insurance, just follow this link:",
                            buttonTitle: "Get a new price"
                        )

                    ],
                    escalationReference: "escalationReference"
                )
            ),
            status: .sent
        ),
        conversationStatus: .open,
        vm: .init(chatService: service),
        showRetryOptions: true
    )
}

#Preview(body: {
    Dependencies.shared.add(module: Module { () -> ConversationClient in ConversationsDemoClient() })
    let service = ConversationService(conversationId: "conversationId")

    return MessageView(
        message: .init(
            id: "messageId",
            sender: .hedvig,
            sentAt: Date(),
            type: .action(
                action: .init(
                    url: URL("")!,
                    text: "A new conversation has been created by Hedvig.",
                    buttonTitle: "Go to conversation"
                )
            ),
            status: .failed(error: "error")
        ),
        conversationStatus: .open,
        vm: .init(chatService: service),
        showRetryOptions: true
    )
})
