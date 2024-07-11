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

enum ChatNavigationTracking: TrackingViewNameProtocol {
    var nameForTracking: String {
        return .init(describing: ChatScreen.self)
    }

    case chatScren
}

public struct ChatNavigation<Content: View>: View {
    @StateObject var router = Router()
    @StateObject var chatNavigationViewModel = ChatNavigationViewModel()
    let openChat: ChatTopicWrapper
    @ViewBuilder var redirectView: (_ type: ChatRedirectViewType, _ onDone: @escaping () -> Void) -> Content
    var onUpdateDate: (Date) -> Void
    public init(
        openChat: ChatTopicWrapper,
        @ViewBuilder redirectView: @escaping (_ type: ChatRedirectViewType, _ onDone: @escaping () -> Void) -> Content,
        onUpdateDate: @escaping (Date) -> Void
    ) {
        self.openChat = openChat
        self.redirectView = redirectView
        self.onUpdateDate = onUpdateDate

    }

    public var body: some View {
        RouterHost(router: router, options: .navigationType(type: .large), tracking: ChatNavigationTracking.chatScren) {
            ChatScreen(vm: .init(topicType: openChat.topic))
                .navigationTitle(L10n.chatTitle)
                .withDismissButton()
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
    ChatNavigation(openChat: .init(topic: nil, onTop: true)) { type, onDone in
        EmptyView()
    } onUpdateDate: { _ in

    }
}
