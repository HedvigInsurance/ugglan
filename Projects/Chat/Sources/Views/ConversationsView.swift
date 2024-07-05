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
        .padding(.top, 8)
        .onPullToRefresh {
            await vm.fetchMessages()
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
        .withoutHorizontalPadding
        .sectionContainerStyle(.transparent)
    }

    func rowView(for conversation: Conversation) -> some View {
        HStack(spacing: .padding16) {
            if vm.shouldHideDivider(for: conversation) {
                hRow {
                    rowViewContent(for: conversation)
                }
                .hWithoutDivider
            } else {
                hRow {
                    rowViewContent(for: conversation)
                }
            }
        }
        .background(getBackgroundColor(for: conversation))
    }

    @ViewBuilder
    func rowViewContent(for conversation: Conversation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                if conversation.type == .legacy {
                    hText(L10n.chatConversationHistoryTitle, style: .body1)
                        .foregroundColor(hTextColor.Opaque.primary)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        hText(conversation.title, style: .body1)
                            .fixedSize()
                            .foregroundColor(hTextColor.Opaque.primary)
                        hText(conversation.subtitle ?? "", style: .body1)
                            .fixedSize()
                            .foregroundColor(hTextColor.Translucent.secondary)
                    }
                }
                Spacer()
                getRightView(for: conversation)
            }

            getNewestMessage(for: conversation)
                .padding(.bottom, 2)
        }
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
            .transition(.scale.combined(with: .opacity))
        } else if let timeStamp = conversation.newestMessage?.sentAt {
            hText(timeStamp.displayTimeStamp, style: .footnote)
                .foregroundColor(hTextColor.Opaque.secondary)
                .transition(.scale.combined(with: .opacity))
        }
    }

    @ViewBuilder
    private func getNewestMessage(for conversation: Conversation) -> some View {
        if let newestMessage = conversation.newestMessage {
            hText(newestMessage.latestMessageText, style: .footnote)
                .foregroundColor(hTextColor.Translucent.primary)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(getNewestMessageColor(for: conversation))
        }
    }

    @hColorBuilder
    private func getBackgroundColor(for conversation: Conversation) -> some hColor {
        if vm.hasNotification(conversation: conversation) {
            hSurfaceColor.Translucent.primary
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
        return store.hasNotification(
            conversationId: conversation.id,
            timeStamp: conversation.newestMessage?.sentAt ?? conversation.createdAt?.localDateToIso8601Date
        )
    }

    func shouldHideDivider(for conversation: Conversation) -> Bool {
        let currentConversationHasNotification = hasNotification(conversation: conversation)

        if !currentConversationHasNotification {
            return false
        }

        var convWithNotificationAndOldestTimestamp = conversation

        conversations.forEach { conversation in
            if hasNotification(conversation: conversation) {
                let oldestTimeStamp = convWithNotificationAndOldestTimestamp.newestMessage?.sentAt ?? Date()
                let currentTimestamp = conversation.newestMessage?.sentAt ?? Date()

                if oldestTimeStamp > currentTimestamp {
                    convWithNotificationAndOldestTimestamp = conversation
                }
            }
        }

        // current conversation is oldest
        if convWithNotificationAndOldestTimestamp.id == conversation.id {
            return true
        }

        // there are older conversations
        return false
    }

    init() {
        let store: ChatStore = globalPresentableStoreContainer.get()
        conversationTimeStampCancellable = store.stateSignal.plain().publisher
            .map({ $0.conversationsTimeStamp })
            .receive(on: RunLoop.main)
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
            withAnimation {
                self.conversations = conversations
            }
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
