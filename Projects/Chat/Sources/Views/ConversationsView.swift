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
        .hWithoutDividerPadding
        .padding(.horizontal, -16)
        .sectionContainerStyle(.transparent)
    }

    func rowView(for conversation: Conversation) -> some View {
        HStack(spacing: .padding16) {
            hRow {
                Circle()
                    .frame(width: 10)
                    .foregroundColor(getNotificationColor(for: conversation))
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, .padding8)

                if conversation.type == .legacy {
                    legacyView(conversation: conversation)
                } else {
                    conversationView(conversation: conversation)
                }
            }
        }
        .background(getBackgroundColor(for: conversation))
    }

    func legacyView(conversation: Conversation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                hText("Conversation history", style: .body1)
                Spacer()
                if let timeStamp = conversation.newestMessage?.sentAt {
                    hText(getDateStamp(for: timeStamp), style: .footnote)
                }
            }
            getNewestMessage(conversation: conversation)
        }
        .foregroundColor(hTextColor.Opaque.secondary)
    }

    @ViewBuilder
    func conversationView(conversation: Conversation) -> some View {
        VStack(alignment: .leading, spacing: .padding4) {
            hText(conversation.title, style: .body1)
            hText(conversation.subtitle ?? "", style: .footnote)
            getNewestMessage(conversation: conversation)
                .padding(.top, .padding4)
        }

        Spacer()
        if let timeStamp = conversation.newestMessage?.sentAt {
            hText(getDateStamp(for: timeStamp), style: .footnote)
                .foregroundColor(hTextColor.Opaque.accordion)
        }
    }

    @ViewBuilder
    private func getNewestMessage(conversation: Conversation) -> some View {
        if let newestMessage = conversation.newestMessage {
            switch newestMessage.type {
            case let .text(text):
                var textToDisplay: String {
                    if newestMessage.sender == .hedvig {
                        return "Hedvig: " + text
                    } else {
                        return "You: " + text
                    }
                }
                hText(textToDisplay, style: .footnote)
                    .fixedSize(horizontal: false, vertical: true)
            default:
                EmptyView()
            }
        }
    }

    @hColorBuilder
    private func getNotificationColor(for conversation: Conversation) -> some hColor {
        if conversation.type != .legacy {
            if vm.hasNotification(conversation: conversation) {
                hSignalColor.Blue.element
            } else {
                hColorBase(.clear)
            }
        } else {
            hColorBase(.clear)
        }
    }

    @hColorBuilder
    private func getBackgroundColor(for conversation: Conversation) -> some hColor {
        if conversation.type != .legacy {
            if vm.hasNotification(conversation: conversation) {
                hSurfaceColor.Opaque.primary
            } else {
                hColorBase(.clear)
            }
        } else {
            hColorBase(.clear)
        }
    }

    private func getDateStamp(for date: Date) -> String {
        if date.isToday {
            return "Today " + date.displayTimeStamp
        } else if date.isYesterday {
            return "Yesterday " + date.displayTimeStamp
        }
        return date.displayDateDDMMMMYYYYFormat ?? ""
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
    Dependencies.shared.add(module: Module { () -> ConversationsClient in ConversationsDemoClient() })
    return ConversationsView()
}
