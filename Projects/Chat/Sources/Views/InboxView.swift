import Combine
import SwiftUI
import hCore
import hCoreUI

public struct InboxView: View {
    @StateObject var vm = InboxViewModel()
    @Namespace var animationNamespace

    public init() {}

    public var body: some View {
        hForm {
            displayMessages
                .padding(.top, 8)
        }
        .hSetScrollBounce(to: true)
        .onPullToRefresh {
            await vm.fetchMessages()
        }
    }

    @ViewBuilder
    var displayMessages: some View {
        hSection(vm.conversations) { conversation in
            rowView(for: conversation)
                .onTapGesture {
                    NotificationCenter.default.post(
                        name: .openChat,
                        object: ChatType.conversationId(id: conversation.id)
                    )
                }
                .accessibilityAddTraits(.isButton)
                .background(getBackgroundColor(for: conversation))
        }
        .hWithoutHorizontalPadding([.section])
        .sectionContainerStyle(.transparent)
    }

    func rowView(for conversation: Conversation) -> some View {
        hRow {
            rowViewContent(for: conversation)
        }
        .shouldShowDivider(vm.shouldHideDivider(for: conversation))
    }

    func rowViewContent(for conversation: Conversation) -> some View {
        VStack(alignment: .leading, spacing: .padding8) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    hText(conversation.getConversationTitle, style: .body1)
                        .lineLimit(3)
                    Spacer()
                    getRightView(for: conversation)
                        .fixedSize()
                }
                if let subtitle = conversation.getConversationSubTitle {
                    hText(subtitle, style: .body1)
                        .foregroundColor(getNewestMessageColor(for: conversation))
                        .lineLimit(3)
                }
            }
            getNewestMessage(for: conversation)
                .padding(.bottom, 2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private func getRightView(for conversation: Conversation) -> some View {
        if conversation.hasNewMessage {
            hText(L10n.chatNewMessage, style: .label)
                .foregroundColor(hSignalColor.Blue.text)
                .padding(.horizontal, .padding6)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(hHighlightColor.Blue.fillOne)
                )
                .transition(.scale.combined(with: .opacity))
                .matchedGeometryEffect(id: "rightView_\(conversation.id)", in: animationNamespace)
        } else if conversation.isClosed {
            hText(L10n.chatConversationClosed, style: .label)
                .foregroundColor(hTextColor.Opaque.secondary)
                .padding(.horizontal, .padding6)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(hSurfaceColor.Opaque.primary)
                )
                .transition(.scale.combined(with: .opacity))
                .matchedGeometryEffect(id: "rightView_\(conversation.id)", in: animationNamespace)
        } else if let timeStamp = conversation.newestMessage?.sentAt {
            ZStack {
                hText(" ", style: .body1)
                hText(timeStamp.displayTimeStamp, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
            .transition(.scale.combined(with: .opacity))
            .matchedGeometryEffect(id: "rightView_\(conversation.id)", in: animationNamespace)
        }
    }

    @ViewBuilder
    private func getNewestMessage(for conversation: Conversation) -> some View {
        if let newestMessage = conversation.newestMessage {
            hText(newestMessage.latestMessageText, style: .label)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(getNewestMessageColor(for: conversation))
        }
    }

    @hColorBuilder
    private func getBackgroundColor(for conversation: Conversation) -> some hColor {
        if conversation.hasNewMessage {
            hSurfaceColor.Translucent.primary
        } else {
            hColorBase(.clear)
        }
    }

    @hColorBuilder
    private func getNewestMessageColor(for conversation: Conversation) -> some hColor {
        if conversation.hasNewMessage {
            hTextColor.Translucent.primary
        } else {
            hTextColor.Translucent.secondary
        }
    }
}

@MainActor
class InboxViewModel: ObservableObject {
    @Inject var service: ConversationsClient
    @Published var conversations: [Conversation] = []
    private var pollTimerCancellable: AnyCancellable?
    private var chatClosedObserver: NSObjectProtocol?

    func shouldHideDivider(for conversation: Conversation) -> Bool {
        guard let indexOfCurrent = conversations.firstIndex(where: { $0.id == conversation.id }) else {
            return true
        }
        let indexOfNext = indexOfCurrent + 1
        guard indexOfNext < conversations.count else {
            return true
        }
        let currentConversation = conversations[indexOfCurrent]
        let nextConversation = conversations[indexOfNext]
        return currentConversation.hasNewMessage != nextConversation.hasNewMessage
    }

    init() {
        configureFetching()
        chatClosedObserver = NotificationCenter.default.addObserver(forName: .chatClosed, object: nil, queue: nil) {
            [weak self] _ in
            Task {
                await self?.configureFetching()
            }
        }
    }

    private func configureFetching() {
        pollTimerCancellable = nil
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
            withAnimation {
                self.conversations = conversations
            }
        } catch _ {
            // TODO: EXCEPTION
        }
    }

    deinit {
        Task { @MainActor [weak self] in
            if let chatClosedObserver = self?.chatClosedObserver {
                NotificationCenter.default.removeObserver(chatClosedObserver)
            }
        }
    }
}

#Preview {
    let client = ConversationsDemoClient()
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> ConversationClient in client })
    Dependencies.shared.add(module: Module { () -> ConversationsClient in client })
    return InboxView()
}
