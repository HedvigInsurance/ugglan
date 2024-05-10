import SwiftUI
import hCore
import hCoreUI

public class ChatNavigationViewModel: ObservableObject {
    @Published var isFilePresented: FileUrlModel?

    struct FileUrlModel: Identifiable, Equatable {
        public var id: String?
        var url: URL
    }
}

public struct ChatNavigation: View {
    @StateObject var router = Router()
    @StateObject var chatNavigationViewModel = ChatNavigationViewModel()
    let openChat: ChatTopicWrapper

    public init(
        openChat: ChatTopicWrapper
    ) {
        self.openChat = openChat
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
    }
}

#Preview{
    ChatNavigation(openChat: .init(topic: nil, onTop: true))
}
