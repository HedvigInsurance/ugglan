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
            rowView(for: conversation)
                .onTapGesture {
                    NotificationCenter.default.post(name: .openChat, object: conversation)
                }
        }
        .padding(.horizontal, -16)
        .sectionContainerStyle(.transparent)
    }

    func rowView(for conversation: Conversation) -> some View {
        HStack(spacing: .padding16) {
            hRow {
                VStack(alignment: .leading, spacing: .padding4) {
                    if conversation.type == .legacy {
                        hText(L10n.chatConversationHistoryTitle, style: .body1)
                    } else {
                        hText(conversation.title, style: .body1)
                            .foregroundColor(hTextColor.Opaque.primary)
                        hText(conversation.subtitle ?? "", style: .body1)
                            .fixedSize()
                            .foregroundColor(hTextColor.Translucent.secondary)
                    }
                    getNewestMessage(for: conversation)
                        .padding(.top, .padding4)
                }
                Spacer()
                getRightView(for: conversation)
            }
        }
        .background(getBackgroundColor(for: conversation))
    }

    @ViewBuilder
    private func getRightView(for conversation: Conversation) -> some View {
        if vm.hasNotification(conversation: conversation) {
            HStack {
                hText(L10n.chatNewMessage, style: .footnote)
                    .foregroundColor(hTextColor.Opaque.black)
            }
            .padding(.horizontal, .padding6)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(hHighlightColor.Blue.fillTwo)
            )
        } else if let timeStamp = conversation.newestMessage?.sentAt {
            hText(timeStamp.displayTimeStamp, style: .footnote)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
    }

    @ViewBuilder
    private func getNewestMessage(for conversation: Conversation) -> some View {
        if let newestMessage = conversation.newestMessage {
            switch newestMessage.type {
            case let .text(text):
                var textToDisplay: String {
                    if newestMessage.sender == .hedvig {
                        return "\(L10n.chatSenderHedvig): " + text
                    } else {
                        return "\(L10n.chatSenderMember): " + text
                    }
                }
                hText(textToDisplay, style: .footnote)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(getNewestMessageColor(for: conversation))
            default:
                EmptyView()
            }
        }
    }

    @hColorBuilder
    private func getBackgroundColor(for conversation: Conversation) -> some hColor {
        if vm.hasNotification(conversation: conversation) {
            hHighlightColor.Blue.fillOne
        } else {
            hColorBase(.clear)
        }
    }

    @hColorBuilder
    private func getNewestMessageColor(for conversation: Conversation) -> some hColor {
        if vm.hasNotification(conversation: conversation) {
            hTextColor.Translucent.primary
        } else {
            hTextColor.Opaque.secondary
        }
    }
}

class ConversationsViewModel: ObservableObject {
    @Inject var service: ConversationsClient
    @Published var conversations: [Conversation] = []
    @Published private var conversationsTimeStamp = [String: Date]()
    private var conversationTimeStampCancellable: AnyCancellable?
    private var pollTimerCancellable: AnyCancellable?
    @PresentableStore var store: ChatStore

    func hasNotification(conversation: Conversation) -> Bool {
        return store.hasNotification(conversationId: conversation.id, timeStamp: conversation.newestMessage?.sentAt)
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
    Dependencies.shared.add(module: Module { () -> ConversationsClient in ConversationsDemoClient() })
    return ConversationsView()
}
