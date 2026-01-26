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
            if case .failed = message.status {
                messageFailContent
                    .modifier(MessageViewBackground(message: message, conversationStatus: conversationStatus))
            } else {
                messageContent
                    .modifier(MessageViewBackground(message: message, conversationStatus: conversationStatus))
            }
        }
        .frame(
            maxWidth: 300,
            alignment: message.sender.alignment
        )
        .onTapGesture {
            if case .failed = message.status {
                Task {
                    await vm.messageVm.retrySending(message: message)
                }
            }
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(
            {
                if case .failed = message.status {
                    return .isButton
                }
                return AccessibilityTraits()
            }()
        )
        .id("MessageView_\(message.id)")
        .modifier(MessageViewConfirmationDialog(message: message, showRetryOptions: $showRetryOptions, vm: vm))
    }

    @ViewBuilder
    private var messageContent: some View {
        switch message.type {
        case let .text(_, action):
            VStack(spacing: .padding16) {
                MarkdownView(
                    config: .init(
                        text: message.trimmedText,
                        fontStyle: .body1,
                        color: message.textColor,
                        linkColor: hTextColor.Opaque.primary,
                        linkUnderlineStyle: .thick,
                        maxWidth: 300,
                        isSelectable: true,
                        onUrlClicked: { url in
                            NotificationCenter.default.post(name: .openDeepLink, object: url)
                        }
                    )
                )
                .hEnvironmentAccessibilityLabel(message.timeStampString)
                if let action {
                    hButton(
                        .large,
                        .secondary,
                        content: .init(title: action.buttonTitle)
                    ) {
                        NotificationCenter.default
                            .post(name: .openDeepLink, object: action.url)
                    }
                    .padding(.horizontal, -message.horizontalPadding)
                    .padding(.bottom, .padding4)
                }
            }
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
                        isSelectable: true,
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
        case .unknown: Text("")
        }
    }

    private func accessilityLabel(for message: Message) -> String {
        var displayString = ""
        switch message.type {
        case .text:
            displayString = message.trimmedText
        case let .file(file):
            displayString = file.mimeType.isImage ? L10n.voiceoverChatImage : L10n.voiceoverChatFile
        case .deepLink:
            displayString = L10n.chatSentALink
        case .otherLink:
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
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel(L10n.voiceoverMoreInfo)
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
        return contractStore.state.contractForId(contractIdString ?? "")?.currentAgreement?
            .productVariant.displayName
    }
}

#Preview(body: {
    Dependencies.shared.add(module: Module { () -> ConversationClient in ConversationsDemoClient() })
    let service = ConversationService(conversationId: "conversationId")

    return VStack {
        MessageView(
            message: .init(
                id: "messageId2",
                sender: .hedvig,
                sentAt: Date(),
                type: .text(
                    text: "text that we want to use here for the member",
                    action: .init(url: URL(filePath: "")!, text: nil, buttonTitle: "Button title")
                ),
                disclaimer: nil,
                status: .received
            ),
            conversationStatus: .open,
            vm: .init(chatService: service),
            showRetryOptions: false
        )
    }
})
