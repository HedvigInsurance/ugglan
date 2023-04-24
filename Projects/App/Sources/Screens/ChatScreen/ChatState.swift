import Apollo
import Flow
import Form
import Foundation
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

class ChatState {
    static var shared = ChatState()
    private let bag = DisposeBag()
    private let subscriptionBag = DisposeBag()
    private let editBag = DisposeBag()
    @Inject private var giraffe: hGiraffe
    private var handledGlobalIds: [GraphQLID] = []
    private var hasShownStatusMessage = false
    var allowNewMessageToast = true

    let isEditingSignal = ReadWriteSignal<Bool>(false)
    let currentMessageSignal: ReadSignal<Message?>
    let errorSignal = ReadWriteSignal< (Error?, retry:(() -> ())?)>((nil, retry: nil))
    let listSignal = ReadWriteSignal<[ChatListContent]>([])
    let tableSignal: ReadSignal<Table<EmptySection, ChatListContent>>
    let filteredListSignal: ReadSignal<[ChatListContent]>

    private func parseMessage(message: GiraffeGraphQL.MessageData) -> [ChatListContent] {
        var result: [ChatListContent] = []
        let newMessage = Message(from: message, listSignal: filteredListSignal)

        if let paragraph = message.body.asMessageBodyParagraph {
            if !filteredListSignal.value.contains(where: { content -> Bool in content.right != nil }) {
                result.append(.make(TypingIndicator(listSignal: filteredListSignal)))
            }

            if paragraph.text != "" { result.append(.make(newMessage)) }
        } else {
            result.append(.make(newMessage))
        }
        return result
    }

    private func handleFirstMessage(message: GiraffeGraphQL.MessageData) {
        if message.body.asMessageBodyParagraph != nil {
            bag += Signal(after: TimeInterval(Double(message.header.pollingInterval) / 1000))
                .onValue { _ in self.fetch(cachePolicy: .fetchIgnoringCacheData) }
        }

        if let statusMessage = message.header.statusMessage, !hasShownStatusMessage {
            hasShownStatusMessage = true
            let innerBag = bag.innerBag()

            func createToast() -> Toast {
                if UIApplication.shared.isRegisteredForRemoteNotifications {
                    return Toast(symbol: .icon(hCoreUIAssets.chat.image), body: statusMessage)
                }

                return Toast(
                    symbol: .icon(hCoreUIAssets.chat.image),
                    body: statusMessage,
                    subtitle: L10n.chatToastPushNotificationsSubtitle
                )
            }

            let toast = createToast()

            innerBag += toast.onTap.onValue { _ in
                UIApplication.shared.appDelegate.registerForPushNotifications().sink()
            }

            Toasts.shared.displayToast(toast: toast)
        }
    }

    func fetch(cachePolicy: CachePolicy = .returnCacheDataAndFetch, hasFetched: @escaping () -> Void = {}) {
        bag +=
            giraffe.client
            .fetch(
                query: GiraffeGraphQL.ChatMessagesQuery(),
                cachePolicy: cachePolicy,
                queue: DispatchQueue.global(qos: .background)
            )
            .onError({ error in
                log.error("Chat Error: ChatMessagesQuery", error: error, attributes: nil)
                self.errorSignal.value = (ChatError.fetchFailed, retry: {
                    self.fetch(cachePolicy: cachePolicy, hasFetched: hasFetched)
                })
            })
            .valueSignal
            .compactMap(on: .concurrentBackground) { data -> [GiraffeGraphQL.MessageData]? in
                data.messages.compactMap { message in message?.fragments.messageData }
            }
            .map { messages in
                messages.filter { message -> Bool in
                    if self.handledGlobalIds.contains(message.globalId) { return false }

                    self.handledGlobalIds.append(message.globalId)

                    return true
                }
            }
            .atValue { _ in hasFetched() }.filter(predicate: { messages -> Bool in !messages.isEmpty })
            .atValue { messages in
                if let message = messages.first { self.handleFirstMessage(message: message) }
            }
            .onValue { messages in
                self.listSignal.value.insert(
                    contentsOf: messages.flatMap { self.parseMessage(message: $0) },
                    at: 0
                )

                if cachePolicy == .returnCacheDataAndFetch {
                    self.fetch(cachePolicy: .fetchIgnoringCacheData)
                }
            }
    }

    @discardableResult func subscribe() -> CoreSignal<Plain.DropReadWrite, GiraffeGraphQL.MessageData> {
        subscriptionBag.dispose()
        let signal =
            giraffe.client
            .subscribe(
                subscription: GiraffeGraphQL.ChatMessagesSubscriptionSubscription(),
                queue: DispatchQueue.global(qos: .background)
            )
            .compactMap(on: .concurrentBackground) { $0.message.fragments.messageData }
            .filter(predicate: { message -> Bool in
                if self.handledGlobalIds.contains(message.globalId) { return false }

                self.handledGlobalIds.append(message.globalId)

                return true
            })
            .atValue { message in self.handleFirstMessage(message: message)
                self.listSignal.value.insert(contentsOf: self.parseMessage(message: message), at: 0)
            }

        subscriptionBag += signal.nil()

        return signal
    }

    func reset() {
        handledGlobalIds = []
        listSignal.value = []
        bag += giraffe.client.perform(mutation: GiraffeGraphQL.TriggerResetChatMutation())
            .onValue { _ in self.fetch(cachePolicy: .fetchIgnoringCacheData) }
            .onError({ error in
                log.error("Chat Error: TriggerResetChatMutation", error: error, attributes: nil)
                self.errorSignal.value = (ChatError.fetchFailed, retry: {
                    self.reset()
                })
            })
    }

    func sendSingleSelectResponse(selectedValue: GraphQLID) {
        bag += currentMessageSignal.atOnce().take(first: 1).compactMap { $0?.globalId }
            .onValue { globalId in
                self.bag += self.giraffe.client
                    .perform(
                        mutation: GiraffeGraphQL.SendChatSingleSelectResponseMutation(
                            globalId: globalId,
                            selectedValue: selectedValue
                        )
                    )
                    .onValue { _ in self.fetch(cachePolicy: .fetchIgnoringCacheData) }
                    .onError({ error in
                        log.error("Chat Error: SendChatSingleSelectResponseMutation", error: error, attributes: nil)
                        self.errorSignal.value = (ChatError.mutationFailed, retry: {
                            self.sendSingleSelectResponse(selectedValue: selectedValue)
                        })
                    })
            }
    }

    func sendChatFreeTextResponse(text: String) -> Signal<Void> {
        Signal { callback in
            let innerBag = DisposeBag()

            hAnalyticsEvent.chatTextMessageSent().send()

            innerBag += self.currentMessageSignal.atOnce().take(first: 1).compactMap { $0?.globalId }
                .take(first: 1)
                .onValue { globalId in
                    innerBag += self.giraffe.client
                        .perform(
                            mutation: GiraffeGraphQL.SendChatTextResponseMutation(
                                globalId: globalId,
                                text: text
                            )
                        )
                        .onValue { _ in callback(())
                            self.fetch(cachePolicy: .fetchIgnoringCacheData)
                        }.onError({ error in
                            log.error("Chat Error: SendChatTextResponseMutation", error: error, attributes: nil)
                            self.errorSignal.value = (ChatError.mutationFailed, retry: {
                               innerBag += self.sendChatFreeTextResponse(text: text)
                            })
                        })
                }

            return innerBag
        }
    }

    func sendChatFileResponseMutation(key: String, mimeType: String) {
        hAnalyticsEvent.chatRichMessageSent().send()

        bag += currentMessageSignal.atOnce().take(first: 1).compactMap { $0?.globalId }
            .onValue { globalId in
                self.bag += self.giraffe.client
                    .perform(
                        mutation: GiraffeGraphQL.SendChatFileResponseMutation(
                            globalID: globalId,
                            key: key,
                            mimeType: mimeType
                        )
                    )
                    .onValue { _ in self.fetch(cachePolicy: .fetchIgnoringCacheData) }
                    .onError({ error in
                        log.error("Chat Error: SendChatFileResponseMutation", error: error, attributes: nil)
                        self.errorSignal.value = (ChatError.mutationFailed, retry: {
                            self.sendChatFileResponseMutation(key: key, mimeType: mimeType)
                        })
                    })
            }
    }

    func sendChatAudioResponse(fileUrl: URL) {
        guard let file = try? GraphQLFile(fieldName: "file", originalName: "recording.mp3", fileURL: fileUrl)
        else { return }

        bag += currentMessageSignal.atOnce().take(first: 1).compactMap { $0?.globalId }
            .onValue { globalId in
                self.bag += self.giraffe.client
                    .upload(
                        operation: GiraffeGraphQL.SendChatAudioResponseMutation(
                            globalID: globalId,
                            file: "file"
                        ),
                        files: [file]
                    )
                    .onValue { _ in self.fetch(cachePolicy: .fetchIgnoringCacheData) }
                    .onError({ error in
                        log.error("Chat Error: SendChatAudioResponseMutation", error: error, attributes: nil)
                        self.errorSignal.value = (ChatError.mutationFailed, retry: {
                            self.sendChatAudioResponse(fileUrl: fileUrl)
                        })
                    })
            }
    }

    init() {
        filteredListSignal = listSignal.atOnce()
            .map(on: .background) { messages in
                messages.enumerated()
                    .compactMap { offset, item -> ChatListContent? in
                        if item.right != nil { if offset != 0 { return nil } }

                        if item.left?.responseType == .audio { return item }

                        if item.left?.body == "", !(item.left?.type.isRichType ?? false) {
                            return nil
                        }

                        return item
                    }
            }

        currentMessageSignal = listSignal.atOnce().map { list in list.first?.left }
        tableSignal = filteredListSignal.atOnce().distinct().map(on: .background) { Table(rows: $0) }

        editBag += listSignal.atOnce()
            .onValueDisposePrevious(on: .background) { messages -> Disposable? in
                let innerBag = DisposeBag()

                innerBag += messages.prefix(10)
                    .map { message -> Disposable in
                        message.left?.onEditCallbacker
                            .addCallback { _ in self.bag.dispose()

                                guard
                                    let firstIndex = self.listSignal.value
                                        .firstIndex(where: { message -> Bool in
                                            message.left?.fromMyself == true
                                        })
                                else { return }

                                self.isEditingSignal.value = true

                                self.listSignal.value = self.listSignal.value
                                    .enumerated()
                                    .filter { offset, _ -> Bool in
                                        offset > firstIndex
                                    }
                                    .map { $0.1 }

                                self.bag += self.giraffe.client
                                    .perform(
                                        mutation:
                                            GiraffeGraphQL.EditLastResponseMutation()
                                    )
                                    .onValue { _ in self.fetch() }
                            } ?? DisposeBag()
                    }

                return innerBag
            }

        editBag += isEditingSignal.onValue { isEditing in
            self.listSignal.value.compactMap { $0.left }
                .forEach { message in message.editingDisabledSignal.value = isEditing }
        }
    }
}


enum ChatError: Error {
    case fetchFailed
    case mutationFailed
}

extension ChatError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fetchFailed: return L10n.General.errorBody
        case .mutationFailed: return L10n.General.errorBody
        }
    }
}
