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

    public var body: some View {
        HStack(spacing: 0) {
            if case .failed = message.status {
                messageFailContent
            } else {
                messageContent
            }
        }
        .frame(
            maxWidth: 300,
            alignment: message.sender.alignment
        )
        .foregroundColor(message.textColor)
        .onTapGesture {
            if case .failed = message.status {
                Task {
                    await vm.retrySending(message: message)
                }
            }
        }
        .id("MessageView_\(message.id)")
        .modifier(MessageViewConfirmationDialog(message: message, showRetryOptions: $showRetryOptions, vm: vm))
    }

    private var messageContent: some View {
        Group {
            switch message.type {
            case .text:
                MarkdownView(
                    config: .init(
                        text: message.trimmedText,
                        fontStyle: .body1,
                        color: hTextColor.Opaque.primary,
                        linkColor: hTextColor.Opaque.primary,
                        linkUnderlineStyle: .thick,
                        maxWidth: 300,
                        onUrlClicked: { url in
                            NotificationCenter.default.post(name: .openDeepLink, object: url)
                        }
                    )
                )

            case let .file(file):
                ChatFileView(file: file, status: message.status).frame(maxHeight: 200)
            case let .crossSell(url):
                LinkView(vm: .init(url: url))
            case let .deepLink(url):
                if let type = DeepLink.getType(from: url) {
                    Button {
                        NotificationCenter.default.post(name: .openDeepLink, object: url)
                    } label: {
                        hText(type.wholeText(displayText: url.contractName ?? type.importantText))
                            .foregroundColor(hTextColor.Opaque.primary)
                            .multilineTextAlignment(.leading)
                    }
                } else {
                    MarkdownView(
                        config: .init(
                            text: url.absoluteString,
                            fontStyle: .body1,
                            color: hTextColor.Opaque.primary,
                            linkColor: hTextColor.Opaque.primary,
                            linkUnderlineStyle: .thick,
                            maxWidth: 300,
                            onUrlClicked: { url in
                                NotificationCenter.default.post(name: .openDeepLink, object: url)
                            }
                        )
                    )
                }
            case let .otherLink(url):
                LinkView(
                    vm: .init(url: url)
                )
            case let .action(action):
                ActionView(action: action)
            case .unknown: Text("")
            }
        }
        .modifier(MessageViewBackground(message: message, conversationStatus: conversationStatus))
    }

    @ViewBuilder
    private var messageFailContent: some View {
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
            .padding(.vertical, .padding24)
            .onTapGesture {
                showRetryOptions = true
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
                        await vm?.retrySending(message: message)
                    }
                }
                Button(L10n.General.remove, role: .destructive) {
                    vm?.deleteFailed(message: message)
                }
                Button(L10n.generalCancelButton, role: .cancel) {
                }
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

#Preview(body: {
    Dependencies.shared.add(module: Module { () -> ConversationClient in ConversationsDemoClient() })
    let service = ConversationService(conversationId: "conversationId")

    return MessageView(
        message: .init(
            localId: nil,
            remoteId: nil,
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
