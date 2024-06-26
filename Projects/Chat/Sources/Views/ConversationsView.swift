import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct ConversationsView: View {
    @StateObject var vm = ConversationsViewModel()

    public init() {}

    public var body: some View {
        hForm {
            displayMessages
        }
    }

    @ViewBuilder
    var displayMessages: some View {
        hSection(vm.conversations) { conversation in
            HStack {
                if conversation.type == .legacy {
                    hRow {
                        HStack(spacing: 16) {
                            Image(uiImage: hCoreUIAssets.activeInbox.image)
                                .resizable()
                                .frame(width: 10, height: 9)
                                .foregroundColor(hFillColor.Opaque.secondary)
                            hText("Conversation history until " + Date().localDateString, style: .footnote)
                        }
                    }
                } else {
                    hRow {
                        HStack {
                            Circle()
                                .frame(width: 8)
                                .foregroundColor(getNotificationColor(for: conversation))
                                .frame(maxHeight: .infinity, alignment: .top)
                                .padding(.top, 8)
                            VStack(alignment: .leading, spacing: 4) {
                                hText(conversation.title, style: .body1)
                                HStack(spacing: 8) {
                                    hText(conversation.subtitle ?? "", style: .footnote)
                                    hText("|")
                                        .foregroundColor(hBorderColor.secondary)
                                    hText("Submitted " + (conversation.createdAt ?? ""), style: .footnote)
                                }
                                .foregroundColor(hTextColor.Opaque.accordion)

                                if let newestMessage = conversation.newestMessage {
                                    switch newestMessage.type {
                                    case let .text(text):
                                        hText(text, style: .footnote)
                                            .padding(.top, 4)
                                    default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .onTapGesture {
                NotificationCenter.default.post(name: .openChat, object: conversation)
            }
        }
        .sectionContainerStyle(.transparent)
    }

    @hColorBuilder
    private func getNotificationColor(for conversation: Conversation) -> some hColor {
        if vm.hasNotification(conversation: conversation) {
            hSignalColor.Red.element
        } else {
            hColorBase(.clear)
        }
    }
}

class ConversationsViewModel: ObservableObject {
    @Inject var service: ConversationsClient
    @Published var conversations: [Conversation] = []
    @Published private var conversationsTimeStamp = [String: Date]()
    private var conversationTimeStampCancellable: AnyCancellable?
    private var pollTimerCancellable: AnyCancellable?

    func hasNotification(conversation: Conversation) -> Bool {
        return conversationsTimeStamp[conversation.id] ?? Date() < conversation.newestMessage?.sentAt ?? Date()
    }

    init() {
        let store: ChatStore = globalPresentableStoreContainer.get()
        conversationTimeStampCancellable = store.stateSignal.plain().publisher
            .map({ $0.conversationsTimeStamp })
            .sink { [weak self] value in
                self?.conversationsTimeStamp = value
            }
        self.conversationsTimeStamp = store.state.conversationsTimeStamp
        Task {
            await fetchMessages()
        }
        pollTimerCancellable = Timer.publish(every: TimeInterval(5), on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                self?.fetchMessages()
            })
    }

    private func fetchMessages() {
        Task { [weak self] in
            await self?.fetchMessages()
        }
    }

    @MainActor
    func fetchMessages() async {
        do {
            let conversations = try await service.getConversations()
            let store: ChatStore = globalPresentableStoreContainer.get()
            let conversationsTimeStamp = store.state.conversationsTimeStamp
            for conversation in conversations {
                if conversationsTimeStamp[conversation.id] == nil,
                    let newestMessageSentAt = conversation.newestMessage?.sentAt
                {
                    await store.sendAsync(
                        .setLastMessageTimestampForConversation(id: conversation.id, date: newestMessageSentAt)
                    )
                }
            }
            self.conversations = conversations
        } catch let ex {
            //TODO: EXCEPTION
        }
    }
}

#Preview{
    Dependencies.shared.add(module: Module { () -> ConversationClient in ConversationDemoClient() })
    return ConversationsView()
}
