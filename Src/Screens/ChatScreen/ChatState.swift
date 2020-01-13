//
//  ChatState.swift
//  test
//
//  Created by Sam Pettersson on 2019-10-02.
//

import Apollo
import Flow
import Form
import Foundation

class ChatState {
    private let bag = DisposeBag()
    private let subscriptionBag = DisposeBag()
    private let editBag = DisposeBag()
    @Inject private var client: ApolloClient
    private var handledGlobalIds: [GraphQLID] = []
    private var hasShownStatusMessage = false

    let isEditingSignal = ReadWriteSignal<Bool>(false)
    let currentMessageSignal: ReadSignal<Message?>
    let listSignal = ReadWriteSignal<[ChatListContent]>([])
    let tableSignal: ReadSignal<Table<EmptySection, ChatListContent>>
    let filteredListSignal: ReadSignal<[ChatListContent]>

    private func parseMessage(message: MessageData) -> [ChatListContent] {
        var result: [ChatListContent] = []
        let newMessage = Message(from: message, listSignal: filteredListSignal)

        if let paragraph = message.body.asMessageBodyParagraph {
            if !filteredListSignal.value.contains(where: { content -> Bool in
                content.right?.left != nil
            }) {
                result.append(.make(.make(TypingIndicator(listSignal: filteredListSignal))))
            }

            if paragraph.text != "" {
                result.append(.make(newMessage))
            }
        } else {
            result.append(.make(newMessage))
        }

        return result
    }

    private func handleFirstMessage(message: MessageData) {
        if message.body.asMessageBodyParagraph != nil {
            bag += Signal(after: TimeInterval(Double(message.header.pollingInterval) / 1000)).onValue { _ in
                self.fetch(cachePolicy: .fetchIgnoringCacheData)
            }
        }

        if let statusMessage = message.header.statusMessage, !hasShownStatusMessage {
            hasShownStatusMessage = true
            let innerBag = bag.innerBag()
            
            func createToast() -> Toast {
                if UIApplication.shared.isRegisteredForRemoteNotifications {
                    return Toast(
                        symbol: .character("✉️"),
                        body: statusMessage
                    )
                }
                
                return Toast(
                    symbol: .character("✉️"),
                    body: statusMessage,
                    subtitle: String(key: .CHAT_TOAST_PUSH_NOTIFICATIONS_SUBTITLE)
                )
            }
            
            let toast = createToast()
            
            innerBag += toast.onTap.onValue { _ in
                UIApplication.shared.appDelegate.registerForPushNotifications().onValue { _ in }
            }
            
            bag += UIApplication.shared.appDelegate.displayToast(toast).onValue { _ in
                innerBag.dispose()
            }
        }
    }

    func fetch(
        cachePolicy: CachePolicy = .returnCacheDataAndFetch,
        hasFetched: @escaping () -> Void = {}
    ) {
        bag += client.fetch(
            query: ChatMessagesQuery(),
            cachePolicy: cachePolicy,
            queue: DispatchQueue.global(qos: .background)
        )
        .valueSignal
        .compactMap(on: .concurrentBackground) { messages -> [MessageData]? in
            messages.data?.messages.compactMap { message in message?.fragments.messageData }
        }
        .map({ messages in
            messages.filter { message -> Bool in
                if self.handledGlobalIds.contains(message.globalId) {
                    return false
                }

                self.handledGlobalIds.append(message.globalId)

                return true
            }
        })
        .atValue({ _ in
            hasFetched()
        })
        .filter(predicate: { messages -> Bool in
            messages.count > 0
        })
        .atValue({ messages in
            if let message = messages.first {
                self.handleFirstMessage(message: message)
            }
        })
        .onValue({ messages in
            self.listSignal.value.insert(contentsOf: messages.flatMap { self.parseMessage(message: $0) }, at: 0)

            if cachePolicy == .returnCacheDataAndFetch {
                self.fetch(cachePolicy: .fetchIgnoringCacheData)
            }
        })
    }

    func subscribe() {
        subscriptionBag.dispose()
        subscriptionBag += client.subscribe(
            subscription: ChatMessagesSubscription(),
            queue: DispatchQueue.global(qos: .background)
        )
        .compactMap(on: .concurrentBackground) { $0.data?.message.fragments.messageData }
        .filter(predicate: { message -> Bool in
            if self.handledGlobalIds.contains(message.globalId) {
                return false
            }

            self.handledGlobalIds.append(message.globalId)

            return true
        })
        .atValue({ message in
            self.handleFirstMessage(message: message)
        })
        .onValue({ message in
            self.listSignal.value.insert(contentsOf: self.parseMessage(message: message), at: 0)
        })
    }

    func reset() {
        handledGlobalIds = []
        listSignal.value = []
        bag += client.perform(mutation: TriggerResetChatMutation()).onValue { _ in
            self.fetch(cachePolicy: .fetchIgnoringCacheData)
        }
    }

    func sendSingleSelectResponse(selectedValue: GraphQLID) {
        bag += currentMessageSignal.atOnce().take(first: 1).compactMap { $0?.globalId }.onValue { globalId in
            self.bag += self.client.perform(
                mutation: SendChatSingleSelectResponseMutation(globalId: globalId, selectedValue: selectedValue)
            ).onValue { _ in
                self.fetch(cachePolicy: .fetchIgnoringCacheData)
            }
        }
    }

    func sendChatFreeTextResponse(text: String) -> Signal<Void> {
        Signal { callback in
            let innerBag = DisposeBag()
            
            innerBag += self.currentMessageSignal.atOnce().take(first: 1).compactMap { $0?.globalId }.take(first: 1).onValue { globalId in
                innerBag += self.client.perform(
                    mutation: SendChatTextResponseMutation(globalId: globalId, text: text)
                ).onValue { _ in
                    callback(())
                    self.fetch(cachePolicy: .fetchIgnoringCacheData)
                }
            }
            
            return innerBag
        }
    }
    
    func sendChatFileResponseMutation(key: String, mimeType: String) {
        bag += currentMessageSignal.atOnce().take(first: 1).compactMap { $0?.globalId }.onValue { globalId in
            self.bag += self.client.perform(
                mutation: SendChatFileResponseMutation(globalID: globalId, key: key, mimeType: mimeType)
            ).onValue { _ in
                self.fetch(cachePolicy: .fetchIgnoringCacheData)
            }
        }
    }

    func sendChatAudioResponse(fileUrl: URL) {
        guard let file = GraphQLFile(fieldName: "file", originalName: "recording.mp3", fileURL: fileUrl) else {
            return
        }

        bag += currentMessageSignal.atOnce().take(first: 1).compactMap { $0?.globalId }.onValue { globalId in
            self.bag += self.client.upload(
                operation: SendChatAudioResponseMutation(globalID: globalId, file: "file"),
                files: [
                    file,
                ]
            ).onValue { _ in
                self.fetch(cachePolicy: .fetchIgnoringCacheData)
            }
        }
    }

    init() {
        filteredListSignal = listSignal.atOnce().map(on: .background) { messages in
            messages.enumerated().compactMap { offset, item -> ChatListContent? in
                if item.right != nil {
                    if offset != 0 {
                        return nil
                    }
                }

                if item.left?.responseType == .audio {
                    return item
                }

                if item.left?.body == "" && !(item.left?.type.isRichType ?? false) {
                    return nil
                }

                return item
            }
        }

        currentMessageSignal = listSignal.atOnce().map { list in list.first?.left }
        tableSignal = filteredListSignal.atOnce().map(on: .background) { Table(rows: $0) }

        editBag += listSignal.atOnce().onValueDisposePrevious(on: .background) { messages -> Disposable? in
            let innerBag = DisposeBag()

            innerBag += messages.prefix(10).map { message -> Disposable in
                return message.left?.onEditCallbacker.addCallback({ _ in
                    self.bag.dispose()

                    guard let firstIndex = self.listSignal.value.firstIndex(where: { message -> Bool in
                        message.left?.fromMyself == true
                    }) else {
                        return
                    }

                    self.isEditingSignal.value = true

                    self.listSignal.value = self.listSignal.value.enumerated().filter { offset, _ -> Bool in
                        offset > firstIndex
                    }.map { $0.1 }

                    self.bag += self.client.perform(mutation: EditLastResponseMutation()).onValue { _ in
                        self.fetch()
                    }
                }) ?? DisposeBag()
            }

            return innerBag
        }

        editBag += isEditingSignal.onValue { isEditing in
            self.listSignal.value.compactMap { $0.left }.forEach { message in
                message.editingDisabledSignal.value = isEditing
            }
        }
    }
}
