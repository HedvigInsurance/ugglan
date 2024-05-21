import Combine
import Kingfisher
import Presentation
import SwiftUI
import hCore
import hGraphQL

public class ChatScreenViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var lastDeliveredMessage: Message?
    @Published var isFetchingNext = false
    @Published var scrollToMessage: Message?
    @Published var banner: Markdown?
    @Published var chatInputVm: ChatInputViewModel = .init()
    @Inject private var fetchMessagesClient: FetchMessagesClient
    @Inject private var sendMessageClient: SendMessageClient
    private var addedMessagesIds: [String] = []
    private var nextUntil: String?
    private var hasNext: Bool?
    private var isFetching = false
    private let topicType: ChatTopicType?
    private var haveSentAMessage = false
    private var storeActionSignal: AnyCancellable?
    public init(topicType: ChatTopicType?) {
        self.topicType = topicType
        chatInputVm.sendMessage = { [weak self] message in
            Task { [weak self] in
                await self?.send(message: message)
            }
        }
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            Task { [weak self] in
                await self?.fetch()
            }
        }
        Task { [weak self] in
            await self?.fetch()
        }
        let fileUploadManager = FileUploadManager()
        fileUploadManager.resetuploadFilesPath()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            AskForRating().askAccordingToTheNumberOfSessions()
        }
        log.addUserAction(type: .click, name: "Chat open", error: nil, attributes: nil)
        NotificationCenter.default.addObserver(forName: .openDeepLink, object: nil, queue: nil) {
            [weak self] notification in guard let self = self else { return }
            if let deepLinkUrl = notification.object as? URL {
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

    deinit {
        let fileUploadManager = FileUploadManager()
        fileUploadManager.resetuploadFilesPath()
        NotificationCenter.default.removeObserver(self)
    }

    @MainActor
    func fetchNext() async {
        if let hasNext, let nextUntil, hasNext, !isFetchingNext {
            withAnimation {
                isFetchingNext = true
            }
            await fetch(with: nextUntil)
            withAnimation {
                isFetchingNext = false
            }
        }
    }

    @MainActor
    private func fetch(with next: String? = nil) async {
        do {
            let chatData = try await fetchMessagesClient.get(next)
            let newMessages = chatData.messages.filterNotAddedIn(list: addedMessagesIds)
            if !newMessages.isEmpty {
                if next != nil {
                    handleNext(messages: newMessages)
                } else {
                    withAnimation {
                        self.banner = chatData.banner
                    }
                    handleInitial(messages: newMessages)
                }
                addedMessagesIds.append(contentsOf: newMessages.compactMap({ $0.id }))
            }
            if next == nil && nextUntil == nil {
                self.hasNext = chatData.hasNext
                if self.hasNext == true {
                    self.nextUntil = chatData.nextUntil
                }
            } else if next != nil {
                self.hasNext = chatData.hasNext
                self.nextUntil = chatData.nextUntil
            }
        } catch _ {
            if let next = next {
                if #available(iOS 16.0, *) {
                    try! await Task.sleep(for: .seconds(2))
                } else {
                    try! await Task.sleep(nanoseconds: 2_000_000_000)
                }
                await fetch(with: next)
            }
        }
    }

    private func handleInitial(messages: [Message]) {
        withAnimation {
            self.messages.insert(contentsOf: messages, at: 0)
            sortMessages()
        }
        if let lastMessage = messages.first {
            handleLastMessageTimeStamp(for: lastMessage)
        }
    }

    private func handleNext(messages: [Message]) {
        withAnimation {
            self.messages.append(contentsOf: messages)
            sortMessages()
        }
    }

    private func sortMessages() {
        self.messages.sort(by: { $0.sentAt > $1.sentAt })
        self.lastDeliveredMessage = self.messages.first(where: { $0.sender == .member })
    }

    @MainActor
    func send(message: Message) async {
        handleAddingLocal(for: message)
        await sendToClient(message: message)
    }

    @MainActor
    func retrySending(message: Message) async {
        await sendToClient(message: message)
    }

    private func sendToClient(message: Message) async {
        do {
            let data = try await sendMessageClient.send(message: message, topic: topicType)
            if let remoteMessage = data.message {
                await handleSuccessAdding(for: remoteMessage, to: message)
            }
            haveSentAMessage = true
        } catch let ex {
            await handleSendFail(for: message, with: ex.localizedDescription)
        }
    }

    private func handleAddingLocal(for message: Message) {
        let store: ChatStore = globalPresentableStoreContainer.get()
        if !store.state.askedForPushNotificationsPermission {
            store.send(.checkPushNotificationStatus)
        }
        withAnimation {
            messages.insert(message, at: 0)
        }
        addedMessagesIds.append(message.id)
        self.scrollToMessage = message
    }

    @MainActor
    private func handleSuccessAdding(for remoteMessage: Message, to localMessage: Message) {
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
                case .localFile(let url, _):
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        switch remoteMessage.type {
                        case let .file(file):
                            let processor = DownsamplingImageProcessor(
                                size: CGSize(width: 300, height: 300)
                            )
                            var options = KingfisherParsedOptionsInfo.init(nil)
                            options.processor = processor
                            ImageCache.default.store(image, forKey: file.id, options: options)
                        default:
                            break
                        }

                    }
                case .url:
                    break
                }
            }
        default:
            break
        }

        handleLastMessageTimeStamp(for: newMessage)

        addedMessagesIds.append(remoteMessage.id)
        if let index = messages.firstIndex(where: { $0.id == localMessage.id }) {
            withAnimation {
                messages[index] = newMessage
            }
        }
        withAnimation {
            lastDeliveredMessage = self.messages.first(where: { message in
                if case .sent = message.status {
                    return true
                }
                return false
            })
        }
    }

    @MainActor
    private func handleSendFail(for message: Message, with error: String) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            let newMessage = message.asFailed(with: error)
            let oldMessage = messages[index]
            switch oldMessage.status {
            case .failed:
                break
            default:
                messages[index] = newMessage
            }
        }
    }

    private func handleLastMessageTimeStamp(for message: Message) {
        let store: ChatStore = globalPresentableStoreContainer.get()
        store.send(.setLastMessageDate(date: message.sentAt))
    }
}
