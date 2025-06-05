import Combine
import PresentableStore
import SwiftUI
@preconcurrency import UserNotifications
import hCore
import hCoreUI

@MainActor
public class ChatNavigationViewModel: ObservableObject {
    @Published var isFilePresented: DocumentPreviewModel.DocumentPreviewType?
    @Published var isAskForPushNotificationsPresented = false

    init() {}

    private var toastPublisher: AnyCancellable?
    func checkForPushNotificationStatus() async {
        let status = await UNUserNotificationCenter.current().notificationSettings()
        switch status.authorizationStatus {
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

public enum ChatRedirectViewType: Hashable {
    case notification
    case claimDetailForConversationId(id: String)
}

extension ChatRedirectViewType: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .notification:
            return "AskForPushNotifications"
        case .claimDetailForConversationId:
            return "ClaimDetailView"
        }
    }

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
                case let .conversationId(conversationId):
                    ChatScreen(
                        vm: .init(
                            chatService: ConversationService(conversationId: conversationId),
                            onTitleTap: {
                                router.push(ChatRedirectViewType.claimDetailForConversationId(id: conversationId))
                            }
                        )
                    )
                case .newConversation:
                    ChatScreen(
                        vm: .init(
                            chatService: NewConversationService()
                        )
                    )
                case .inbox:
                    InboxView()
                        .configureTitle(L10n.chatConversationInbox)
                }
            }
            .withDismissButton(
                reducedTopSpacing: Int(CGFloat.padding8)
            )
            .routerDestination(for: ChatRedirectViewType.self) { value in
                redirectView(value) {}
            }
        }
        .environmentObject(chatNavigationViewModel)
        .detent(
            item: $chatNavigationViewModel.isFilePresented,
            transitionType: .detent(style: [.large])
        ) { documentType in
            DocumentPreview(vm: .init(type: documentType))
        }
        .detent(
            presented: $chatNavigationViewModel.isAskForPushNotificationsPresented,
            transitionType: .detent(style: [.large])
        ) {
            redirectView(.notification) {
                Task { @MainActor in
                    chatNavigationViewModel.isAskForPushNotificationsPresented = false
                }
            }
        }
    }
}

#Preview {
    ChatNavigation(chatType: .newConversation) { type, onDone in
        EmptyView()
    }
}
