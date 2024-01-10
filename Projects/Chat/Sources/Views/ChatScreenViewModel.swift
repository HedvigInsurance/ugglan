import Combine
import SwiftUI
import hCore

class ChatScreenViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isFetchingNext = false
    @Published var scrollToMessage: Message?
    @Published var inputText: String = ""
    @Inject private var fetchMessagesClient: FetchMessagesClient
    @Inject private var sendMessageClient: SendMessageClient
    private var addedMessagesIds: [String] = []
    private var nextUntil: String?
    private var hasNext: Bool?
    private var isFetching = false

    init() {
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
    }

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
                    self.hasNext = chatData.hasNext
                    self.nextUntil = chatData.nextUntil
                } else {
                    if nextUntil == nil {
                        self.hasNext = chatData.hasNext
                        self.nextUntil = chatData.nextUntil
                    }
                    handleInitial(messages: newMessages)
                }

                addedMessagesIds.append(contentsOf: newMessages.compactMap({ $0.id }))
            }
        } catch let ex {

        }
    }

    private func handleInitial(messages: [Message]) {
        withAnimation {
            self.messages.insert(contentsOf: messages, at: 0)
        }
    }

    private func handleNext(messages: [Message]) {
        withAnimation {
            self.messages.append(contentsOf: messages)
        }
    }

    @MainActor
    func send(file: File) async {
        let message = Message(type: .file(file: file))
        handleAddingLocal(message: message)
        do {
            let data = try await sendMessageClient.send(for: file)
            if let remoteMessage = data.message {
                handleSuccessAdding(remoteMessage: remoteMessage, to: message)
            }
        } catch let ex {

        }
    }

    @MainActor
    func send(text: String) async {
        let message = Message(type: .text(text: text))
        handleAddingLocal(message: message)
        do {
            let data = try await sendMessageClient.send(message: text)
            if let remoteMessage = data.message {
                handleSuccessAdding(remoteMessage: remoteMessage, to: message)
            }
        } catch let ex {

        }
    }

    private func handleAddingLocal(message: Message) {
        withAnimation {
            messages.insert(message, at: 0)
        }
        addedMessagesIds.append(message.id)
        self.scrollToMessage = message
    }

    private func handleSuccessAdding(remoteMessage: Message, to localMessage: Message) {
        let newMessage = Message(
            localId: localMessage.id,
            remoteId: remoteMessage.id,
            type: localMessage.type,
            date: localMessage.sentAt
        )
        addedMessagesIds.append(remoteMessage.id)
        if let index = messages.firstIndex(where: { $0.id == localMessage.id }) {
            messages[index] = newMessage
        }
    }
}
