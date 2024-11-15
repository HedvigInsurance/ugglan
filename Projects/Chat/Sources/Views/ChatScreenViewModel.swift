import Combine
import Kingfisher
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

@MainActor
public class ChatScreenViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var lastDeliveredMessage: Message?
    @Published var isFetchingPreviousMessages = false
    @Published var scrollToMessage: Message?
    @Published var banner: Markdown?
    @Published var conversationStatus: ConversationStatus = .open
    @Published var shouldShowBanner = true
    private var conversationId: String?
    var chatInputVm: ChatInputViewModel = .init()
    @Published var title: String = L10n.chatTitle
    @Published var subTitle: String?
    var chatNavigationVm: ChatNavigationViewModel?
    let chatService: ChatServiceProtocol
    var scrollCancellable: AnyCancellable?
    private var pollTimerCancellable: AnyCancellable?
    var hideBannerCancellable: AnyCancellable?

    private var addedMessagesIds: [String] = []
    private var hasNext: Bool?
    private var isFetching = false
    private var haveSentAMessage = false
    private var openDeepLinkObserver: NSObjectProtocol?
    private var onTitleTap: (String) -> Void?
    private var claimId: String?
    private var sendingMessagesIds = [String]()
    public init(
        chatService: ChatServiceProtocol,
        onTitleTap: @escaping (String) -> Void = { claimId in }
    ) {
        self.chatService = chatService
        self.onTitleTap = onTitleTap

        chatInputVm.sendMessage = { [weak self] message in
            Task { [weak self] in
                if Dependencies.featureFlags().isDemoMode {
                    switch message.type {
                    case .file(let file):
                        if let newFile = file.getAsDataFromUrl() {
                            let fileMessage = message.copyWith(type: .file(file: newFile))
                            await self?.send(message: fileMessage)
                        }
                    default:
                        await self?.send(message: message)
                    }
                } else {
                    await self?.send(message: message)
                }
            }
        }

        hideBannerCancellable = chatInputVm.$showBottomMenu.combineLatest(chatInputVm.$keyboardIsShown)
            .receive(on: RunLoop.main)
            .sink { [weak self] (showBottomMenu, isKeyboardShown) in
                let shouldShowBanner = !showBottomMenu && !isKeyboardShown
                if self?.shouldShowBanner != false {
                    withAnimation {
                        self?.shouldShowBanner = shouldShowBanner
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
                            attributes: ["haveSentAMessage": self.haveSentAMessage]
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
                    await self?.fetchMessages()
                }
            })
        await self.fetchMessages()
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
                        $0.sender == .member && $0.remoteId != nil
                    })
                }
                self.banner = chatData.banner
                self.conversationStatus = chatData.conversationStatus ?? .open
                addedMessagesIds.append(contentsOf: newMessages.compactMap({ $0.id }))
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
    private func fetchMessages() async {
        do {
            let store: ChatStore = globalPresentableStoreContainer.get()
            let chatData = try await chatService.getNewMessages()
            self.conversationId = chatData.conversationId
            let newMessages = chatData.messages.filterNotAddedIn(list: addedMessagesIds)
            withAnimation {
                self.messages.append(contentsOf: newMessages)

                if hasNext == nil {
                    if let conversationId, let failedMessages = store.state.failedMessages[conversationId] {
                        self.messages.insert(contentsOf: failedMessages.reversed(), at: 0)
                        addedMessagesIds.append(contentsOf: failedMessages.compactMap({ $0.id }))
                    }
                }

                self.messages.sort(by: { $0.sentAt > $1.sentAt })
                self.lastDeliveredMessage = self.messages.first(where: { $0.sender == .member && $0.remoteId != nil })
            }
            self.banner = chatData.banner
            self.conversationStatus = chatData.conversationStatus ?? .open
            addedMessagesIds.append(contentsOf: newMessages.compactMap({ $0.id }))

            if hasNext == nil {
                hasNext = chatData.hasPreviousMessage
            }
            title = chatData.title ?? L10n.chatTitle
            subTitle = chatData.subtitle
            claimId = chatData.claimId
        } catch _ {
            //We ignore this errors since we will fetch this every 5 seconds
        }
    }

    @MainActor
    func send(message: Message) async {
        handleAddingLocal(for: message)
        await sendToClient(message: message)
        if title == L10n.chatNewConversationTitle {
            await fetchMessages()
        }
    }

    @MainActor
    func retrySending(message: Message) async {
        await sendToClient(message: message)
    }

    private func sendToClient(message: Message) async {
        if !sendingMessagesIds.contains(message.id) {
            sendingMessagesIds.append(message.id)
            do {
                let sentMessage = try await chatService.send(message: message)
                let store: ChatStore = globalPresentableStoreContainer.get()
                store.send(.clearFailedMessage(conversationId: conversationId ?? "", message: message))
                await handleSuccessAdding(for: sentMessage, to: message)
                haveSentAMessage = true
            } catch let ex {
                await handleSendFail(for: message, with: ex.localizedDescription)
            }
            sendingMessagesIds.removeAll(where: { $0 == message.id })
        }
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
        self.scrollToMessage = message
    }

    @MainActor
    private func handleSuccessAdding(for remoteMessage: Message, to localMessage: Message) async {
        let newMessage = Message(
            localId: localMessage.id,
            remoteId: remoteMessage.id,
            type: remoteMessage.type,
            date: remoteMessage.sentAt
        )
        switch localMessage.type {
        case let .file(file):
            if file.mimeType.isImage {
                switch file.source {
                case .localFile(let results):
                    if let results {
                        if let data = try? await results.itemProvider.getData().data, let image = UIImage(data: data) {
                            let processor = DownsamplingImageProcessor(
                                size: CGSize(width: 300, height: 300)
                            )
                            var options = KingfisherParsedOptionsInfo.init(nil)
                            options.processor = processor
                            try? await ImageCache.default.store(image, forKey: remoteMessage.id, options: options)
                        }
                    }
                    break
                case .url:
                    break
                case .data(let data):
                    if let image = UIImage(data: data) {
                        let processor = DownsamplingImageProcessor(
                            size: CGSize(width: 300, height: 300)
                        )
                        var options = KingfisherParsedOptionsInfo.init(nil)
                        options.processor = processor
                        try? await ImageCache.default.store(image, forKey: remoteMessage.id, options: options)
                    }
                }
            }
        default:
            break
        }

        addedMessagesIds.append(remoteMessage.id)
        if let index = messages.firstIndex(where: { $0.id == localMessage.id }) {
            withAnimation {
                messages[index] = newMessage
                self.messages.sort(by: { $0.sentAt > $1.sentAt })
            }
        }
        withAnimation {
            lastDeliveredMessage = self.messages.first(where: { message in
                if case .sent = message.status {
                    return message.sender == .member
                }
                return false
            })
        }
    }

    func deleteFailed(message: Message) {
        let store: ChatStore = globalPresentableStoreContainer.get()
        withAnimation {
            self.messages.removeAll(where: { $0.id == message.id })
        }
        store.send(.clearFailedMessage(conversationId: conversationId ?? "", message: message))
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
                case .file(let file):
                    if let newFile = try? await file.getAsData() {
                        let fileMessage = newMessage.copyWith(type: .file(file: newFile))
                        store.send(.setFailedMessage(conversationId: conversationId ?? "", message: fileMessage))
                    }
                default:
                    store.send(.setFailedMessage(conversationId: conversationId ?? "", message: newMessage))
                }
            }
        }
    }
}

enum ConversationsError: Error {
    case errorMesage(message: String)
    case missingData
    case uploadFailed
    case missingConversation
}

extension ConversationsError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .errorMesage(message): return message
        case .missingData: return L10n.somethingWentWrong
        case .uploadFailed: return L10n.somethingWentWrong
        case .missingConversation: return L10n.somethingWentWrong
        }
    }
}

extension ChatScreenViewModel: TitleView {
    public func getTitleView() -> UIView {
        let view: UIView = UIHostingController(rootView: titleView).view
        view.backgroundColor = .clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }

    @objc private func handleTapGesture() {
        if let claimId {
            self.onTitleTap(claimId)
        }
    }

    @ViewBuilder
    private var titleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            hText(self.title).foregroundColor(hTextColor.Opaque.primary)
            if let subTitle = subTitle {
                hText(subTitle)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
