import Combine
import Kingfisher
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class ChatConversationViewModel: ObservableObject {
    @Published var conversationStatus: ConversationStatus = .open
    var conversationId: String?
    var claimId: String?
    @Published var banner: Markdown?
    @Published var shouldShowBanner = true
    @Published var title: String = L10n.chatTitle
    @Published var subTitle: String?
}

@MainActor
public class ChatMessageViewModel: ObservableObject {
    let chatService: ChatServiceProtocol
    var chatNavigationVm: ChatNavigationViewModel?
    let conversationVm: ChatConversationViewModel
    private var hasNext: Bool?
    var haveSentAMessage = false
    private var sendingMessagesIds = [String]()
    private var addedMessagesIds: [String] = []

    @Published var scrollToMessage: Message?
    @Published var lastDeliveredMessage: Message?
    @Published var messages: [Message] = []
    @Published var isFetchingPreviousMessages = false

    public init(
        chatService: ChatServiceProtocol
    ) {
        self.chatService = chatService
        conversationVm = .init()
    }

    @MainActor
    func fetchPreviousMessages(retry withAutomaticRetry: Bool = true) async {
        if let hasNext, hasNext, !isFetchingPreviousMessages {
            do {
                isFetchingPreviousMessages = true
                let chatData = try await chatService.getPreviousMessages()
                let newMessages = chatData.messages.filterNotAddedIn(list: addedMessagesIds)

                withAnimation {
                    self.messages.append(contentsOf: newMessages)
                    self.messages.sort(by: { $0.sentAt > $1.sentAt })
                    self.lastDeliveredMessage = self.messages.first(where: {
                        $0.sender == .member
                    })
                }
                conversationVm.banner = chatData.banner
                conversationVm.conversationStatus = chatData.conversationStatus ?? .open
                addedMessagesIds.append(contentsOf: newMessages.compactMap(\.id))
                self.hasNext = chatData.hasPreviousMessage
                isFetchingPreviousMessages = false
            } catch _ {
                if withAutomaticRetry {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    isFetchingPreviousMessages = false
                    await fetchPreviousMessages()
                } else {
                    isFetchingPreviousMessages = false
                }
            }
        }
    }

    @MainActor
    func fetchMessages() async {
        // skip if have message that are in process of sending
        if sendingMessagesIds.isEmpty {
            do {
                let store: ChatStore = globalPresentableStoreContainer.get()
                let chatData = try await chatService.getNewMessages()
                conversationVm.conversationId = chatData.conversationId
                let newMessages = chatData.messages.filterNotAddedIn(list: addedMessagesIds)
                withAnimation {
                    self.messages.append(contentsOf: newMessages)

                    if hasNext == nil {
                        if let conversationId = conversationVm.conversationId,
                            let failedMessages = store.state.failedMessages[conversationId]
                        {
                            self.messages.insert(contentsOf: failedMessages.reversed(), at: 0)
                            addedMessagesIds.append(contentsOf: failedMessages.compactMap(\.id))
                        }
                    }
                    self.messages.sort(by: { $0.sentAt > $1.sentAt })
                    self.lastDeliveredMessage = self.messages.first(where: {
                        $0.sender == .member
                    })
                }
                conversationVm.banner = chatData.banner
                conversationVm.conversationStatus = chatData.conversationStatus ?? .open
                addedMessagesIds.append(contentsOf: newMessages.compactMap(\.id))

                if hasNext == nil {
                    hasNext = chatData.hasPreviousMessage
                }
                conversationVm.title = chatData.title ?? L10n.chatTitle
                conversationVm.subTitle = chatData.subtitle
                conversationVm.claimId = chatData.claimId
            } catch _ {
                // We ignore this errors since we will fetch this every 5 seconds
            }
        }
    }

    private func sendToClient(message: Message) async {
        if !sendingMessagesIds.contains(message.id) {
            sendingMessagesIds.append(message.id)
            do {
                let sentMessage = try await chatService.send(message: message)
                let store: ChatStore = globalPresentableStoreContainer.get()
                store.send(.clearFailedMessage(conversationId: conversationVm.conversationId ?? "", message: message))
                await handleSuccessAdding(for: sentMessage, to: message)
                haveSentAMessage = true
            } catch let ex {
                await handleSendFail(for: message, with: ex.localizedDescription)
            }
            sendingMessagesIds.removeAll(where: { $0 == message.id })
        }
    }

    @MainActor
    func send(message: Message) async {
        handleAddingLocal(for: message)
        await sendToClient(message: message)
        if conversationVm.title == L10n.chatNewConversationTitle {
            await fetchMessages()
        }
    }

    @MainActor
    func retrySending(message: Message) async {
        await sendToClient(message: message)
    }

    private func handleAddingLocal(for message: Message) {
        let store: ChatStore = globalPresentableStoreContainer.get()
        if !store.state.askedForPushNotificationsPermission {
            store.send(.checkPushNotificationStatus)
            Task { @MainActor in
                await chatNavigationVm?.checkForPushNotificationStatus()
            }
        }
        withAnimation {
            messages.insert(message, at: 0)
        }
        addedMessagesIds.append(message.id)
        scrollToMessage = message
    }

    @MainActor
    private func handleSuccessAdding(for remoteMessage: Message, to localMessage: Message) async {
        switch localMessage.type {
        case let .file(file):
            if file.mimeType.isImage {
                switch file.source {
                case let .localFile(results):
                    if let results {
                        if let data = try? await results.itemProvider.getData().data, let image = UIImage(data: data) {
                            let processor = DownsamplingImageProcessor(
                                size: CGSize(width: 300, height: 300)
                            )
                            var options = KingfisherParsedOptionsInfo(nil)
                            options.processor = processor
                            try? await ImageCache.default.store(image, forKey: remoteMessage.id, options: options)
                        }
                    }
                case .url:
                    break
                case let .data(data):
                    if let image = UIImage(data: data) {
                        let processor = DownsamplingImageProcessor(
                            size: CGSize(width: 300, height: 300)
                        )
                        var options = KingfisherParsedOptionsInfo(nil)
                        options.processor = processor
                        try? await ImageCache.default.store(image, forKey: remoteMessage.id, options: options)
                    }
                }
            }
        default:
            break
        }
        addedMessagesIds.append(remoteMessage.id)

        // replace local message with remote one
        if let index = messages.firstIndex(where: { $0.id == localMessage.id }) {
            withAnimation {
                messages[index] = remoteMessage
                self.messages.sort(by: { $0.sentAt > $1.sentAt })
            }
        }

        // add some delay so it looks smoother
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            withAnimation {
                self?.lastDeliveredMessage = self?.messages.first(where: { $0.sender == .member })
            }
        }
    }

    @MainActor
    private func handleSendFail(for message: Message, with error: String) async {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            let newMessage = message.asFailed(with: error)
            let oldMessage = messages[index]
            switch oldMessage.status {
            case .failed:
                break
            default:
                messages[index] = newMessage
                let store: ChatStore = globalPresentableStoreContainer.get()
                switch newMessage.type {
                case let .file(file):
                    if let newFile = try? await file.getAsData() {
                        let fileMessage = newMessage.copyWith(type: .file(file: newFile))
                        store.send(
                            .setFailedMessage(conversationId: conversationVm.conversationId ?? "", message: fileMessage)
                        )
                    }
                default:
                    store.send(
                        .setFailedMessage(conversationId: conversationVm.conversationId ?? "", message: newMessage)
                    )
                }
            }
        }
    }

    func deleteFailed(message: Message) {
        let store: ChatStore = globalPresentableStoreContainer.get()
        withAnimation {
            self.messages.removeAll(where: { $0.id == message.id })
        }
        store.send(.clearFailedMessage(conversationId: conversationVm.conversationId ?? "", message: message))
    }
}

@MainActor
public class ChatScreenViewModel: ObservableObject {
    let chatInputVm: ChatInputViewModel = .init()
    let messageVm: ChatMessageViewModel

    var scrollCancellable: AnyCancellable?
    private var pollTimerCancellable: AnyCancellable?
    var hideBannerCancellable: AnyCancellable?
    private var openDeepLinkObserver: NSObjectProtocol?

    public init(
        chatService: ChatServiceProtocol
    ) {
        messageVm = .init(chatService: chatService)

        chatInputVm.sendMessage = { [weak self] message in
            Task { [weak self] in
                if Dependencies.featureFlags().isDemoMode {
                    switch message.type {
                    case let .file(file):
                        if let newFile = file.getAsDataFromUrl() {
                            let fileMessage = message.copyWith(type: .file(file: newFile))
                            await self?.messageVm.send(message: fileMessage)
                        }
                    default:
                        await self?.messageVm.send(message: message)
                    }
                } else {
                    await self?.messageVm.send(message: message)
                }
            }
        }

        hideBannerCancellable = chatInputVm.$showBottomMenu.combineLatest(chatInputVm.$keyboardIsShown)
            .receive(on: RunLoop.main)
            .sink { [weak self] showBottomMenu, isKeyboardShown in
                let shouldShowBanner = !showBottomMenu && !isKeyboardShown
                if self?.messageVm.conversationVm.shouldShowBanner != false {
                    withAnimation {
                        self?.messageVm.conversationVm.shouldShowBanner = shouldShowBanner
                    }
                }
            }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            AskForRating().askAccordingToTheNumberOfSessions()
        }
        log.addUserAction(type: .click, name: "Chat open", error: nil, attributes: nil)
        openDeepLinkObserver = NotificationCenter.default.addObserver(forName: .openDeepLink, object: nil, queue: nil) {
            [weak self] notification in
            guard let self = self else { return }
            if let deepLinkUrl = notification.object as? URL {
                Task { @MainActor in
                    if let deepLink = DeepLink.getType(from: deepLinkUrl), deepLink == .helpCenter {
                        log.addUserAction(
                            type: .custom,
                            name: "Help center opened from the chat",
                            error: nil,
                            attributes: ["haveSentAMessage": self.messageVm.haveSentAMessage]
                        )
                    }
                }
            }
        }
    }

    deinit {
        Task { @MainActor [weak self] in
            if let openDeepLinkObserver = self?.openDeepLinkObserver {
                NotificationCenter.default.removeObserver(openDeepLinkObserver)
            }
            NotificationCenter.default.post(name: .chatClosed, object: nil)
        }
    }

    @MainActor
    func startFetchingNewMessages() async {
        pollTimerCancellable = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                Task { @MainActor [weak self] in
                    await self?.messageVm.fetchMessages()
                }
            })
        await messageVm.fetchMessages()
    }
    @MainActor
    func escalateMessage(message: Message, automaticSuggestion: AutomaticSuggestions) async {
        /* TODO: ADD IMPLEMENTATION */
    }
}

public enum ConversationsError: Error {
    case errorMesage(message: String)
    case missingData
    case uploadFailed
    case missingConversation
}

extension ConversationsError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .errorMesage(message): return message
        case .missingData: return L10n.somethingWentWrong
        case .uploadFailed: return L10n.somethingWentWrong
        case .missingConversation: return L10n.somethingWentWrong
        }
    }
}
