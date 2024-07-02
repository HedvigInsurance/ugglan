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
    let chatType: ChatType
    @ViewBuilder var redirectView: (_ type: ChatRedirectViewType, _ onDone: @escaping () -> Void) -> Content
    public init(
        chatType: ChatType,
        @ViewBuilder redirectView: @escaping (_ type: ChatRedirectViewType, _ onDone: @escaping () -> Void) -> Content
    ) {
        self.chatType = chatType
        self.redirectView = redirectView
    }

    public var body: some View {
        RouterHost(router: router, options: .navigationType(type: .large)) {
            switch chatType {
            case let .conversation(conversationId):
                ChatScreen(vm: .init(chatService: ConversationService(conversationId: conversationId)))
                    .withDismissButton()
            case let .conversationId(id):
                ChatScreen(vm: .init(chatService: ConversationService(conversationId: id)))
                    .withDismissButton()
            case let .topic(topic):
                ChatScreen(vm: .init(chatService: MessagesService(topic: topic)))
                    .withDismissButton()
            case .newConversation:
                ChatScreen(vm: .init(chatService: NewConversationService()))
                    .withDismissButton()
            case .none:
                ChatScreen(vm: .init(chatService: MessagesService(topic: nil)))
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
    }
}

#Preview{
    ChatNavigation(chatType: .none) { type, onDone in
        EmptyView()
    }
}
