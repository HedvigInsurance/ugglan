import Combine
import StoreContainer
import SwiftUI
import hCore
import hCoreUI

public class ChatNavigationViewModel: ObservableObject {
    @Published var isFilePresented: FileUrlModel?
    @Published var isAskForPushNotificationsPresented = false
    @Published var dateOfLastMessage: Date?
    private var dateOfLastMessageCancellable: AnyCancellable?
    init() {
        let store: ChatStore = hGlobalPresentableStoreContainer.get()
        dateOfLastMessageCancellable = store.actionSignal
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
            func createToast() -> ToastBar {
                return ToastBar(
                    type: .info,
                    text: L10n.chatToastPushNotificationsTitle,
                    action: .init(
                        actionText: L10n.pushNotificationsAlertActionOk,
                        onClick: {
                            NotificationCenter.default.post(name: .registerForPushNotifications, object: nil)
                        }
                    ),
                    duration: 6
                )
            }

            let toast = createToast()
            Toasts.shared.displayToastBar(toast: toast)
        default:
            break
        }
    }
}

public enum ChatRedirectViewType {
    case notification
}

public enum ChatNavigationViewName: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: ChatScreen.self)
    }

    case chat
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
        RouterHost(router: router, options: .navigationType(type: .large), tracking: ChatNavigationViewName.chat) {
            Group {
                switch chatType {
                case let .conversationId(id):
                    ChatScreen(vm: .init(chatService: ConversationService(conversationId: id)))
                case let .topic(topic):
                    ChatScreen(vm: .init(chatService: MessagesService(topic: topic)))
                case .newConversation:
                    ChatScreen(vm: .init(chatService: NewConversationService()))
                case .none:
                    ChatScreen(vm: .init(chatService: MessagesService(topic: nil)))
                }
            }
            .withDismissButton(
                reducedTopSpacing: Dependencies.featureFlags().isConversationBasedMessagesEnabled ? 8 : 0
            )
        }
        .environmentObject(chatNavigationViewModel)
        .detent(
            item: $chatNavigationViewModel.isFilePresented,
            style: .large
        ) { urlModel in
            DocumentPreview(vm: .init(type: .url(url: urlModel.url)))
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
