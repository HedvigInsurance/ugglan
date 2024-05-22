import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI

public class ChatNavigationViewModel: ObservableObject {
    @Published var isFilePresented: FileUrlModel?
    @Published var isAskForPushNotificationsPresented = false

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
                    symbol: .icon(hCoreUIAssets.infoIconFilled.image),
                    body: L10n.chatToastPushNotificationsTitle,
                    infoText: L10n.pushNotificationsAlertActionOk,
                    textColor: hSignalColor.blueText.colorFor(schema == .dark ? .dark : .light, .base).color
                        .uiColor(),
                    backgroundColor: hSignalColor.blueFill.colorFor(schema == .dark ? .dark : .light, .base)
                        .color
                        .uiColor(),
                    symbolColor: hSignalColor.blueElement.colorFor(schema == .dark ? .dark : .light, .base)
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
    @ViewBuilder var redirectView: (_ type: ChatRedirectViewType, _ onDone: @escaping () -> Void) -> Content

    public init(
        openChat: ChatTopicWrapper,
        @ViewBuilder redirectView: @escaping (_ type: ChatRedirectViewType, _ onDone: @escaping () -> Void) -> Content
    ) {
        self.openChat = openChat
        self.redirectView = redirectView
    }

    public var body: some View {
        RouterHost(router: router, options: .navigationType(type: .large)) {
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
    }
}

#Preview{
    ChatNavigation(openChat: .init(topic: nil, onTop: true)) { type, onDone in
        EmptyView()
    }
}
