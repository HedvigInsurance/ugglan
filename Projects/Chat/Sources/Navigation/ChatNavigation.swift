import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI

public class ChatNavigationViewModel: ObservableObject {
    @Published var isFilePresented: FileUrlModel?
    @Published var isAskForPushNotificationsPresented = false
    @Published var dateOfLastMessage: Date?
    private var dateOfLastMessageCancellable: AnyCancellable?
    init() {
        let store: ChatStore = globalPresentableStoreContainer.get()
        dateOfLastMessageCancellable = store.actionSignal.publisher
            .receive(on: RunLoop.main)
            .sink { _ in
            } receiveValue: { [weak self] action in
                switch action {
                case let .setLastMessageDate(date):
                    self?.dateOfLastMessage = date
                default:
                    break
                }
            }
    }

    struct FileUrlModel: Identifiable, Equatable {
        public var id: String?
        var url: URL
    }

    private var toastPublisher: AnyCancellable?
    @MainActor
    func checkForPushNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            self.isAskForPushNotificationsPresented = true
        case .denied:
            func createToast() -> Toast {
                let schema = UITraitCollection.current.userInterfaceStyle
                return Toast(
                    symbol: .icon(hCoreUIAssets.infoFilled.image),
                    body: L10n.chatToastPushNotificationsTitle,
                    infoText: L10n.pushNotificationsAlertActionOk,
                    textColor: hSignalColor.Blue.text.colorFor(schema == .dark ? .dark : .light, .base).color
                        .uiColor(),
                    backgroundColor: hSignalColor.Blue.fill.colorFor(schema == .dark ? .dark : .light, .base)
                        .color
                        .uiColor(),
                    symbolColor: hSignalColor.Blue.element.colorFor(schema == .dark ? .dark : .light, .base)
                        .color
                        .uiColor(),
                    duration: 6
                )
            }

            let toast = createToast()
            toastPublisher = toast.onTap.publisher.sink { _ in
                NotificationCenter.default.post(name: .registerForPushNotifications, object: nil)
            }
            Toasts.shared.displayToast(toast: toast)
        default:
            break
        }
    }
}

public enum ChatRedirectViewType {
    case notification
}

public struct ChatNavigation<Content: View>: View {
    @StateObject var router = Router()
    @StateObject var chatNavigationViewModel = ChatNavigationViewModel()
    let openChat: ChatTopicWrapper
    let conversation: Conversation?
    @ViewBuilder var redirectView: (_ type: ChatRedirectViewType, _ onDone: @escaping () -> Void) -> Content
    var onUpdateDate: (Date) -> Void
    public init(
        openChat: ChatTopicWrapper,
        conversation: Conversation?,
        @ViewBuilder redirectView: @escaping (_ type: ChatRedirectViewType, _ onDone: @escaping () -> Void) -> Content,
        onUpdateDate: @escaping (Date) -> Void
    ) {
        self.openChat = openChat
        self.conversation = conversation
        self.redirectView = redirectView
        self.onUpdateDate = onUpdateDate
    }

    public var body: some View {
        RouterHost(router: router, options: .navigationType(type: .large)) {
            if let conversation {
                ChatScreen(vm: .init(chatService: AllConversationsService(conversationId: conversation.id)))
                    .configureTitle(conversation.title)
                    .withDismissButton()
            } else if let topic = openChat.topic {
                ChatScreen(vm: .init(chatService: MessagesService(topic: topic)))
                    .configureTitle(L10n.chatTitle)
                    .withDismissButton()
            } else {
                // open new conversation
                ChatScreen(vm: .init(chatService: ConversationService()))
                    .configureTitle(L10n.chatTitle)
                    .withDismissButton()
            }
        }
        .environmentObject(chatNavigationViewModel)
        .detent(
            item: $chatNavigationViewModel.isFilePresented,
            style: .large
        ) { urlModel in
            DocumentPreview(url: urlModel.url)
                .withDismissButton()
                .embededInNavigation()
        }
        .detent(
            presented: $chatNavigationViewModel.isAskForPushNotificationsPresented,
            style: .large
        ) {
            redirectView(.notification) {
                Task { @MainActor in
                    chatNavigationViewModel.isAskForPushNotificationsPresented = false
                }
            }
        }
        .onChange(of: chatNavigationViewModel.dateOfLastMessage) { value in
            if let value = value {
                self.onUpdateDate(value)
            }
        }
    }
}

#Preview{
    ChatNavigation(openChat: .init(topic: nil, onTop: true), conversation: nil) { type, onDone in
        EmptyView()
    } onUpdateDate: { _ in

    }
}
