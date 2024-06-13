import Combine
import Kingfisher
import Presentation
import SwiftUI
import hCore
import hGraphQL

public class ChatScreenViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var lastDeliveredMessage: Message?
    @Published var isFetchingPreviousMessages = false
    @Published var scrollToMessage: Message?
    @Published var banner: Markdown?
    @Published var chatInputVm: ChatInputViewModel = .init()
    var chatNavigationVm: ChatNavigationViewModel?
    let chatService: ChatServiceProtocol

    private var addedMessagesIds: [String] = []
    private var hasNext: Bool?
    private var isFetching = false
    private var haveSentAMessage = false

    public init(
        chatService: ChatServiceProtocol
    ) {
        self.chatService = chatService

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
                await self?.fetchMessages()
            }
        }
        Task { [weak self] in
            await self?.fetchMessages()
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
    func fetchPreviousMessages() async {
        if let hasNext, hasNext, !isFetchingPreviousMessages {
            do {
                isFetchingPreviousMessages = true
                let chatData = try await chatService.getPreviousMessages()
                let newMessages = chatData.messages.filterNotAddedIn(list: addedMessagesIds)
                withAnimation {
                    self.messages.append(contentsOf: newMessages)
                    self.messages.sort(by: { $0.sentAt > $1.sentAt })
                    self.lastDeliveredMessage = self.messages.first(where: { $0.sender == .member })
                }
                self.banner = chatData.banner
                addedMessagesIds.append(contentsOf: newMessages.compactMap({ $0.id }))
                self.hasNext = chatData.hasPreviousMessage

                isFetchingPreviousMessages = false
            } catch _ {
                isFetchingPreviousMessages = false
                if #available(iOS 16.0, *) {
                    try! await Task.sleep(for: .seconds(2))
                } else {
                    try! await Task.sleep(nanoseconds: 2_000_000_000)
                }
                await fetchPreviousMessages()
            }
        }
    }

    @MainActor
    private func fetchMessages() async {
        do {
            let chatData = try await chatService.getNewMessages()
            let newMessages = chatData.messages.filterNotAddedIn(list: addedMessagesIds)
            withAnimation {
                self.messages.append(contentsOf: newMessages)
                self.messages.sort(by: { $0.sentAt > $1.sentAt })
                self.lastDeliveredMessage = self.messages.first(where: { $0.sender == .member })
            }
            self.banner = chatData.banner
            addedMessagesIds.append(contentsOf: newMessages.compactMap({ $0.id }))
            hasNext = chatData.hasPreviousMessage
        } catch _ {
            if #available(iOS 16.0, *) {
                try! await Task.sleep(for: .seconds(2))
            } else {
                try! await Task.sleep(nanoseconds: 2_000_000_000)
            }
            await fetchMessages()
        }
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
            let sentMessage = try await chatService.send(message: message)
            await handleSuccessAdding(for: sentMessage, to: message)
            haveSentAMessage = true
        } catch let ex {
            await handleSendFail(for: message, with: ex.localizedDescription)
        }
    }

    private func handleAddingLocal(for message: Message) {
        let store: ChatStore = globalPresentableStoreContainer.get()
        if !store.state.askedForPushNotificationsPermission {
            store.send(.checkPushNotificationStatus)
            Task {
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

public enum ChatServiceType {
    case conversation
    case oldChat
}

public protocol ChatServiceProtocol {
    var type: ChatServiceType { get }
    func getNewMessages() async throws -> ChatData
    func getPreviousMessages() async throws -> ChatData
    func send(message: Message) async throws -> Message
}
