import Apollo
import Chat
import Combine
import Flow
import Form
import Foundation
import Home
import LinkPresentation
import Presentation
import Profile
import UIKit
import hCore
import hCoreUI
import hGraphQL

class ChatState {
    static var shared = ChatState()
    private let bag = DisposeBag()
    private let subscriptionBag = DisposeBag()
    @Inject private var octopus: hOctopus

    private var handledGlobalIds: [GraphQLID] = []
    private var hasShownStatusMessage = false
    var allowNewMessageToast = true
    let askForPermissionsSignal = ReadWriteSignal<Bool>(false)
    private var initialNextUntil: String?
    private var initialHasNext: Bool = true
    private var nextUntil: String?
    private var hasNext: Bool?
    let isFetching = ReadWriteSignal<Bool>(false)
    let isFetchingNext = ReadWriteSignal<Bool>(false)

    var pollTimer: Publishers.Autoconnect<Timer.TimerPublisher>?
    var fetchTimerCancellable: AnyCancellable?

    let isEditingSignal = ReadWriteSignal<Bool>(false)
    let currentMessageSignal: ReadSignal<Message?>
    let errorSignal = ReadWriteSignal<(ChatError?, retry: (() -> Void)?)>((nil, retry: nil))
    let listSignal = ReadWriteSignal<[ChatListContent]>([])
    let tableSignal: ReadSignal<Table<EmptySection, ChatListContent>>
    let filteredListSignal: ReadSignal<[ChatListContent]>
    let showDelivered = ReadWriteSignal<Bool>(false)

    private let profileStore: ProfileStore = globalPresentableStoreContainer.get()

    private func parseMessage(message: OctopusGraphQL.MessageFragment) -> [ChatListContent] {
        var result: [ChatListContent] = []
        let newMessage = Message(from: message, listSignal: filteredListSignal)
        result.append(.make(newMessage))
        return result
    }

    private func handleFirstMessage() {
        if !hasShownStatusMessage {
            hasShownStatusMessage = true
            let innerBag = bag.innerBag()
            let status = self.profileStore.state.pushNotificationCurrentStatus()
            switch status {
            case .notDetermined:
                self.askForPermissionsSignal.value = true
            case .denied:
                func createToast() -> Toast {
                    let schema = UITraitCollection.current.userInterfaceStyle
                    return Toast(
                        symbol: .icon(hCoreUIAssets.infoIconFilled.image),
                        body: L10n.chatToastPushNotificationsTitle,
                        infoText: L10n.pushNotificationsAlertActionOk,
                        textColor: hSignalColor.blueText.colorFor(schema == .dark ? .dark : .light, .base).color
                            .uiColor(),
                        backgroundColor: hSignalColor.blueFill.colorFor(schema == .dark ? .dark : .light, .base).color
                            .uiColor(),
                        symbolColor: hSignalColor.blueElement.colorFor(schema == .dark ? .dark : .light, .base).color
                            .uiColor(),
                        duration: 6
                    )
                }

                let toast = createToast()
                innerBag += toast.onTap.onValue { _ in
                    UIApplication.shared.appDelegate.registerForPushNotifications().sink()
                }
                Toasts.shared.displayToast(toast: toast)
            default:
                break

            }
        }
    }

    func initFetch() {
        fetch()
        pollTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
        fetchTimerCancellable = pollTimer?
            .sink { value in
                self.fetch()
            }
    }

    func fetchNext(cachePolicy: CachePolicy = .returnCacheDataAndFetch) {
        if !isFetchingNext.value && hasNext ?? initialHasNext == true {
            isFetchingNext.value = true
            bag +=
                octopus.client
                .fetch(
                    query: OctopusGraphQL.ChatQuery(until: nextUntil ?? initialNextUntil),
                    cachePolicy: cachePolicy,
                    queue: DispatchQueue.global(qos: .background)
                )
                .onError({ error in
                    self.isFetchingNext.value = false
                    log.error("Chat Error: ChatMessagesQuery", error: error, attributes: nil)
                    self.errorSignal.value = (
                        ChatError.fetchFailed,
                        retry: {
                            self.fetch(cachePolicy: cachePolicy)
                        }
                    )
                })
                .valueSignal
                .compactMap(on: .concurrentBackground) { data -> [OctopusGraphQL.MessageFragment]? in
                    self.isFetchingNext.value = false
                    self.hasNext = data.chat.hasNext
                    self.nextUntil = data.chat.nextUntil
                    return data.chat.messages.compactMap({ $0.fragments.messageFragment })
                }
                .map { messages in
                    messages.filter { message -> Bool in
                        if self.handledGlobalIds.contains(message.id) { return false }
                        self.handledGlobalIds.append(message.id)
                        return true
                    }
                }
                .onValue { messages in
                    self.listSignal.value.insert(
                        contentsOf: messages.flatMap { self.parseMessage(message: $0) },
                        at: self.listSignal.value.count
                    )
                    if cachePolicy == .returnCacheDataAndFetch {
                        self.fetch(cachePolicy: .fetchIgnoringCacheData)
                    }
                }
        }
    }

    private func fetch(cachePolicy: CachePolicy = .fetchIgnoringCacheCompletely, hasFetched: @escaping () -> Void = {})
    {
        isFetching.value = true
        bag +=
            octopus.client
            .fetch(
                query: OctopusGraphQL.ChatQuery(),
                cachePolicy: cachePolicy,
                queue: DispatchQueue.global(qos: .background)
            )
            .onError({ error in
                self.isFetching.value = false
                if UIApplication.shared.applicationState == .active {
                    self.fetchTimerCancellable = nil
                    log.error("Chat Error: ChatMessagesQuery", error: error, attributes: nil)
                    self.errorSignal.value = (
                        ChatError.fetchFailed,
                        retry: {
                            self.initFetch()
                        }
                    )
                }
            })
            .valueSignal
            .compactMap(on: .concurrentBackground) { data -> [OctopusGraphQL.MessageFragment]? in
                let store: HomeStore = globalPresentableStoreContainer.get()
                store.send(
                    .setChatNotificationTimeStamp(
                        sentAt: data.chat.messages.first?.sentAt.localDateToIso8601Date ?? Date()
                    )
                )
                self.isFetching.value = false
                self.initialHasNext = data.chat.hasNext
                self.initialNextUntil = data.chat.nextUntil
                return data.chat.messages.compactMap({ $0.fragments.messageFragment })
            }
            .map { messages in
                messages.filter { message -> Bool in
                    if self.handledGlobalIds.contains(message.id) { return false }
                    self.handledGlobalIds.append(message.id)
                    return true
                }
            }
            .atValue { _ in hasFetched() }.filter(predicate: { messages -> Bool in !messages.isEmpty })
            .atValue { _ in
                self.handleFirstMessage()
            }
            .onValue { messages in
                let messages = messages.flatMap { self.parseMessage(message: $0) }
                if let lastMessage = messages.first?.left {
                    self.showDelivered.value = lastMessage.fromMyself
                }
                self.listSignal.value.insert(
                    contentsOf: messages,
                    at: 0
                )

                if cachePolicy == .returnCacheDataAndFetch {
                    self.fetch(cachePolicy: .fetchIgnoringCacheData)
                }
            }
    }

    func reset() {
        handledGlobalIds = []
        listSignal.value = []
        pollTimer = nil
        fetchTimerCancellable = nil
        initialNextUntil = nil
        initialHasNext = false
        nextUntil = nil
        hasNext = nil
    }

    func sendChatFreeTextResponse(text: String) -> Signal<Void> {
        Signal { callback in
            let innerBag = DisposeBag()
            innerBag += self.octopus.client
                .perform(
                    mutation: OctopusGraphQL.ChatSendTextMutation(input: .init(text: text))
                )
                .onValue { _ in callback(())
                    self.handleFirstMessage()
                    self.fetch(cachePolicy: .fetchIgnoringCacheData)
                }
                .onError({ error in
                    log.error("Chat Error: SendChatTextResponseMutation", error: error, attributes: nil)
                    self.errorSignal.value = (
                        ChatError.mutationFailed,
                        retry: {
                            innerBag += self.sendChatFreeTextResponse(text: text)
                        }
                    )
                })
            //                }

            return innerBag
        }
    }

    func sendChatFileResponseMutation(key: String) {
        //        bag += currentMessageSignal.atOnce().take(first: 1).compactMap { $0?.globalId }
        //            .onValue { globalId in
        self.bag += self.octopus.client
            .perform(
                mutation: OctopusGraphQL.ChatSendFileMutation(input: .init(uploadToken: key))
            )
            .onValue { _ in self.fetch(cachePolicy: .fetchIgnoringCacheData) }
            .onError({ error in
                log.error("Chat Error: SendChatFileResponseMutation", error: error, attributes: nil)
                self.errorSignal.value = (
                    ChatError.mutationFailed,
                    retry: {
                        self.sendChatFileResponseMutation(key: key)
                    }
                )
            })
        //            }
    }

    init() {
        filteredListSignal = listSignal.atOnce()
            .map(on: .background) { messages in
                messages.enumerated()
                    .compactMap { offset, item -> ChatListContent? in
                        if item.right != nil { if offset != 0 { return nil } }

                        if item.left?.body == "", !(item.left?.type.isRichType ?? false) {
                            return nil
                        }

                        return item
                    }
            }

        currentMessageSignal = listSignal.atOnce()
            .map {
                list in list.first?.left

            }
        tableSignal = filteredListSignal.atOnce().distinct().map(on: .background) { Table(rows: $0) }
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

class WebMetaDataProvider {
    static let shared = WebMetaDataProvider()
    private init() {}
    private var cache: [URL: WebMetaDataProviderData] = [:]

    func data(for url: URL) -> WebMetaDataProviderData? {
        return cache[url]
    }

    func data(for url: URL, closure: @escaping (WebMetaDataProviderData?) -> Void) {
        if let data = cache[url] {
            closure(data)
        } else {
            let metadataProvider = LPMetadataProvider()
            metadataProvider.startFetchingMetadata(for: url) { metadata, error in
                if let metadata {
                    if #available(iOS 16.0, *) {
                        _ = metadata.imageProvider?
                            .loadDataRepresentation(
                                for: .png,
                                completionHandler: { [weak self] data, error in
                                    if let data, let image = UIImage(data: data) {
                                        self?.cache[url] = WebMetaDataProviderData(
                                            title: metadata.title ?? "",
                                            image: image
                                        )
                                    } else {
                                        self?.cache[url] = WebMetaDataProviderData(
                                            title: metadata.title ?? "",
                                            image: nil
                                        )
                                    }
                                    DispatchQueue.main.async { [weak self] in
                                        closure(self?.cache[url])
                                    }
                                }
                            )
                    } else {
                        closure(nil)
                    }
                } else {
                    closure(nil)
                }
            }
        }
    }
}
protocol OldChatFileUploaderClient {
    func upload(file: UploadFile) throws -> Flow.Future<OldChatUploadFileResponseModel>
}

struct OldChatUploadFileResponseModel: Decodable {
    let uploadToken: String
}

enum FileUploadRequest {
    case uploadFile(file: UploadFile)

    var baseUrl: URL {
        return Environment.current.botServiceApiURL
    }

    var methodType: String {
        switch self {
        case .uploadFile:
            return "POST"
        }
    }

    var asRequest: Flow.Future<URLRequest> {
        var request: URLRequest!
        switch self {
        case let .uploadFile(file):
            var baseUrlString = baseUrl.absoluteString
            baseUrlString.append("api/files/upload")
            let url = URL(string: baseUrlString)!
            let multipartFormDataRequest = MultipartFormDataRequest(url: url)
            multipartFormDataRequest.addDataField(
                fieldName: "files",  //file.name,
                fileName: file.name,
                data: file.data,
                mimeType: file.mimeType
            )
            request = multipartFormDataRequest.asURLRequest()
        }
        request.httpMethod = self.methodType
        return Future { completion in
            TokenRefresher.shared.refreshIfNeeded()
                .onValue {
                    let headers = ApolloClient.headers()
                    headers.forEach { element in
                        request.setValue(element.value, forHTTPHeaderField: element.key)
                    }
                    completion(.success(request))
                }
            return NilDisposer()
        }
    }
}

struct WebMetaDataProviderData {
    let title: String
    let image: UIImage?

    init(title: String, image: UIImage?) {
        self.title = title
        self.image = image
    }
}
extension NetworkClient: OldChatFileUploaderClient {
    func upload(file: UploadFile) throws -> Flow.Future<OldChatUploadFileResponseModel> {
        return Future { [weak self] completion in
            FileUploadRequest.uploadFile(file: file).asRequest
                .onValue { request in
                    let task = self?.sessionClient
                        .dataTask(
                            with: request,
                            completionHandler: { (data, response, error) in
                                do {
                                    if let data: [OldChatUploadFileResponseModel] = try self?
                                        .handleResponse(data: data, response: response, error: error)
                                    {
                                        if let responseModel = data.first {
                                            completion(.success(responseModel))
                                        }
                                    }
                                } catch let error {
                                    completion(.failure(error))
                                }
                            }
                        )
                    task?.resume()
                }
            return NilDisposer()
        }
    }
}
