import Combine
import Flow
import Presentation
import SwiftUI
import hCore

class ChatScreenViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var lastDeliveredMessage: Message?
    @Published var isFetchingNext = false
    @Published var scrollToMessage: Message?
    @Published var chatInputVm: ChatInputViewModel = .init()
    @Inject private var fetchMessagesClient: FetchMessagesClient
    @Inject private var sendMessageClient: SendMessageClient
    private var addedMessagesIds: [String] = []
    private var nextUntil: String?
    private var hasNext: Bool?
    private var isFetching = false

    init() {
        chatInputVm.sendMessage = { message in
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
                    if lastDeliveredMessage == nil {
                        withAnimation {
                            self.lastDeliveredMessage = newMessages.first(where: { $0.sender == .member })
                        }
                    }
                    handleNext(messages: newMessages)
                    self.hasNext = chatData.hasNext
                    self.nextUntil = chatData.nextUntil
                } else {
                    withAnimation {
                        self.lastDeliveredMessage = newMessages.first(where: { $0.sender == .member })
                    }
                    if nextUntil == nil {
                        self.hasNext = chatData.hasNext
                        self.nextUntil = chatData.nextUntil
                    }
                    handleInitial(messages: newMessages)
                }

                addedMessagesIds.append(contentsOf: newMessages.compactMap({ $0.id }))
            }
        } catch let ex {
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
            self.messages.sort(by: { $0.sentAt > $1.sentAt })
        }
    }

    private func handleNext(messages: [Message]) {
        withAnimation {
            self.messages.append(contentsOf: messages)
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
            let data = try await sendMessageClient.send(message: message)
            if let remoteMessage = data.message {
                await handleSuccessAdding(for: remoteMessage, to: message)
            }
        } catch let ex {
            await handleSendFail(for: message, with: ex.localizedDescription)
        }
    }

    private func handleAddingLocal(for message: Message) {
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
            type: localMessage.type,
            date: remoteMessage.sentAt
        )
        let store: ChatStore = globalPresentableStoreContainer.get()
        store.send(.setLastMessageDate(date: remoteMessage.sentAt))

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
            messages[index] = newMessage
        }
    }
}
