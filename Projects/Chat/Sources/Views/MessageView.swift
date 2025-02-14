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
    @State var height: CGFloat = 0
    @State var width: CGFloat = 0
    @State var showRetryOptions = false
    @ViewBuilder
    public var body: some View {
        HStack(spacing: 0) {
            messageContent
                .environment(\.colorScheme, .light)
            if case .failed = message.status, message.sender != .automatic {
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

    @ViewBuilder
    private var messageContent: some View {
        HStack {
            if case .failed = message.status, message.sender != .automatic {
                hCoreUIAssets.refresh.view
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(hSignalColor.Red.element)
            }
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
                    .environment(\.colorScheme, .light)

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
                                .environment(\.colorScheme, .light)
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
                        .environment(\.colorScheme, .light)
                    }
                case let .otherLink(url):
                    LinkView(
                        vm: .init(url: url)
                    )
                case let .action(action):
                    ActionView(action: action, message: message, vm: vm)
                        .environment(\.colorScheme, .light)
                case let .automaticSuggestions(suggestions):
                    ForEach(suggestions.suggestions, id: \.self) { action in
                        if let action {
                            VStack(spacing: .padding8) {
                                if case .failed = message.status {
                                    ActionView(
                                        action: action,
                                        message: message,
                                        vm: vm,
                                        isAutomatedMessage: true,
                                        showAsFailed: false
                                    )
                                    .padding(.trailing, .padding32)
                                } else {
                                    ActionView(
                                        action: action,
                                        message: message,
                                        vm: vm,
                                        isAutomatedMessage: true,
                                        showAsFailed: false
                                    )
                                }
                                if suggestions.escalationReference != nil {
                                    HStack(alignment: .top, spacing: 0) {
                                        ActionView(
                                            action: .init(
                                                url: nil,
                                                text:
                                                    L10n.Chatbot.TalkToHuman.text,
                                                buttonTitle: L10n.Chatbot.TalkToHuman.buttonTitle
                                            ),
                                            message: message,
                                            vm: vm
                                        )
                                        if case .failed = message.status {
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
                            }
                            .environment(\.colorScheme, .light)
                        }
                    }
                case .unknown: Text("")
                }
            }
            .padding(.horizontal, message.horizontalPadding)
            .padding(.vertical, message.verticalPadding)
            .background(message.bgColor(conversationStatus: conversationStatus, type: message.type))
            .clipShape(RoundedRectangle(cornerRadius: .padding12))
        }

    }
}

struct LinkView: View {
    @StateObject var vm: LinkViewModel
    @State var height: CGFloat = 0
    @State var width: CGFloat = 0
    var body: some View {
        if let error = vm.error {
            MarkdownView(
                config: .init(
                    text: error,
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
            .environment(\.colorScheme, .light)
            .padding(.padding16)
            .transition(.opacity)
        } else if let model = vm.webMetaDataProviderData {
            VStack(spacing: .padding8) {
                Image(uiImage: model.image ?? hCoreUIAssets.helipadOutlined.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minHeight: 200)
                VStack(spacing: .padding8) {
                    hText(model.title)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    hButton.MediumButton(type: .primaryAlt) {
                        NotificationCenter.default.post(name: .openDeepLink, object: vm.url)
                    } content: {
                        hText(L10n.ImportantMessage.readMore)
                    }
                    .hButtonTakeFullWidth(true)

                }
                .padding([.horizontal, .bottom], .padding16)
            }
            .transition(.opacity)
            .frame(width: 300)
        } else {
            ProgressView()
                .foregroundColor(hTextColor.Opaque.primary)
                .frame(width: 300, height: 200)
                .transition(.opacity)
        }
    }
}

@MainActor
class LinkViewModel: ObservableObject {
    @Published var webMetaDataProviderData: WebMetaDataProviderData?
    @Published var error: String?
    let url: URL

    init(url: URL) {
        self.url = url
        getData()

    }

    @MainActor
    func getData() {
        Task {
            do {
                if let webMetaDataProviderData = try await WebMetaDataProvider.shared.data(for: url) {
                    withAnimation {
                        self.webMetaDataProviderData = webMetaDataProviderData
                    }
                } else {
                    withAnimation {
                        self.error = url.absoluteString
                    }
                }
            } catch let ex {
                withAnimation {
                    error = ex.localizedDescription
                }
            }
        }
    }
}

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
            }
            VStack(spacing: .padding16) {
                if let text = action.text {
                    hText(text, style: .body1)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let automaticSuggestion {
                    hButton.SmallButton(type: .ghost) {
                        Task {
                            await vm.escalateMessage(message: message, automaticSuggestion: automaticSuggestion)
                        }
                    } content: {
                        hText(action.buttonTitle)
                    }
                    .hButtonTakeFullWidth(true)
                } else {
                    hButton.MediumButton(type: .secondary) {
                        NotificationCenter.default.post(name: .openDeepLink, object: action.url)
                    } content: {
                        HStack {
                            hText(action.buttonTitle)
                                .frame(maxWidth: .infinity)
                            if isAutomatedMessage {
                                Image(uiImage: hCoreUIAssets.chevronRight.image)
                                    .frame(alignment: .trailing)
                            }
                        }
                    }
                    .hButtonTakeFullWidth(true)
                }
            }
        }
        .environment(\.colorScheme, .light)
        .padding(.horizontal, .padding16)
        .padding(.vertical, .padding12)
        .background(backgroundColor(messageStatus: message.status, showAsFailed: showAsFailed))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @hColorBuilder
    private func backgroundColor(messageStatus: MessageStatus, showAsFailed: Bool) -> some hColor {
        if case .failed = messageStatus, showAsFailed {
            hSignalColor.Red.highlight
        } else {
            hSurfaceColor.Opaque.primary
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

    let url = URL(string: "https://hedvig.com")

    return MessageView(
        message: .init(
            localId: nil,
            remoteId: nil,
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
        height: 300,
        width: 300,
        showRetryOptions: true
    )
})

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
            status: .sent
        ),
        conversationStatus: .open,
        vm: .init(chatService: service),
        height: 300,
        width: 300,
        showRetryOptions: true
    )
})
