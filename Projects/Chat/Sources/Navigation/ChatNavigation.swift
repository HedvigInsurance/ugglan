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
    @Published var isAutomationMessagePresented: InfoViewDataModel?
    let router = Router()
    let chatType: ChatType
    init(chatType: ChatType) {
        self.chatType = chatType
    }

    func checkForPushNotificationStatus() async {
        let status = await UNUserNotificationCenter.current().notificationSettings()
        switch status.authorizationStatus {
        case .notDetermined:
            isAskForPushNotificationsPresented = true
        case .denied:
            func createToast() -> ToastBar {
                ToastBar(
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

    func showClaimDetail(claimId: String) {
        if case .conversationFromClaimWithId = chatType {
            //came from claim details screen, do nothing
        } else {
            router.push(ChatRedirectViewType.claimDetailFor(claimId: claimId))
        }
    }
}

public enum ChatRedirectViewType: Hashable {
    case notification
    case claimDetailFor(claimId: String)
}

extension ChatRedirectViewType: TrackingViewNameProtocol {
    public var nameForTracking: String {
        switch self {
        case .notification:
            return "AskForPushNotifications"
        case .claimDetailFor:
            return "ClaimDetailView"
        }
    }
}

public enum ChatNavigationViewName: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: ChatScreen.self)
    }

    case chat
}

public struct ChatNavigation<Content: View>: View {
    @ObservedObject private var chatNavigationViewModel: ChatNavigationViewModel

    @ViewBuilder var redirectView: (_ type: ChatRedirectViewType, _ onDone: @escaping () -> Void) -> Content

    public init(
        chatType: ChatType,
        @ViewBuilder redirectView: @escaping (_ type: ChatRedirectViewType, _ onDone: @escaping () -> Void) -> Content
    ) {
        self.chatNavigationViewModel = .init(chatType: chatType)
        self.redirectView = redirectView
    }

    public var body: some View {
        RouterHost(
            router: chatNavigationViewModel.router,
            options: .navigationType(type: .large),
            tracking: ChatNavigationViewName.chat
        ) {
            Group {
                switch chatNavigationViewModel.chatType {
                case let .conversationId(conversationId):
                    ChatScreen(
                        vm: .init(
                            chatService: ConversationService(conversationId: conversationId)
                        )
                    )
                case let .conversationFromClaimWithId(conversationId):
                    ChatScreen(
                        vm: .init(
                            chatService: ConversationService(conversationId: conversationId)
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
        .detent(
            item: $chatNavigationViewModel.isAutomationMessagePresented,
            transitionType: .detent(style: [.height])
        ) { model in
            InfoView(
                title: model.title,
                description: model.description
            )
        }
    }
}

#Preview {
    ChatNavigation(chatType: .newConversation) { _, _ in
        EmptyView()
    }
}
