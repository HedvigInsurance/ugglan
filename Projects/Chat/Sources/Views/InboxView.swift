import Combine
import SwiftUI
import hCore
import hCoreUI

public struct InboxView: View {
    @StateObject var vm = InboxViewModel()
    @InjectObservableObject var featureFlags: FeatureFlags
    @Namespace var animationNamespace
    @State private var isNewMessageSheetPresented = false
    public init() {}

    public var body: some View {
        Group {
            if vm.isInboxEmpty {
                StateView(
                    type: .empty,
                    title: L10n.inboxEmptyStateTitle,
                    bodyText: L10n.inboxEmptyStateSubtitle,
                    formPosition: .center
                )
            } else {
                hForm {
                    displayMessages
                        .padding(.top, 8)
                }
                .hSetScrollBounce(to: true)
            }
        }
        .onPullToRefresh {
            await vm.fetchMessages()
        }
        .loading($vm.processingState)
        .hStateViewButtonConfig(
            .init(
                actionButton: .init(
                    buttonTitle: vm.isInboxEmpty ? L10n.newMessageButton : L10n.generalRetry,
                    buttonAction: { [weak vm] in
                        if vm?.isInboxEmpty == true {
                            isNewMessageSheetPresented = true
                        } else {
                            vm?.configureFetching()
                        }
                    }
                )
            )
        )
        .hStateViewButtonConfig(
            .init(
                actionButton: .init(
                    buttonTitle: L10n.generalRetry,
                    buttonAction: { [weak vm] in
                        vm?.configureFetching()
                    }
                )
            )
        )
        .trackVisibility(as: InboxView.self)
        .toolbar {
            if featureFlags.isNewConversationFromInboxEnabled {
                ToolbarItem(id: "chat", placement: .topBarTrailing) {
                    Button {
                        isNewMessageSheetPresented = true
                    } label: {
                        HStack(alignment: .bottom, spacing: 4) {
                            Image(systemName: "square.and.pencil")
                            hText(L10n.inboxNewMessage, style: .body1)
                        }
                        .padding(.leading, .padding2)
                        .padding(.trailing, .padding3)
                        .foregroundColor(hTextColor.Opaque.primary)
                    }
                    .accessibilityLabel(L10n.newMessageButton)
                }
            }
        }
        .detent(
            presented: $isNewMessageSheetPresented,
            presentationStyle: .detent(style: [.height])
        ) {
            InboxNewMessageSheet()
                .embededInNavigation(
                    options: .navigationBarHidden,
                    tracking: String(describing: InboxNewMessageSheet.self)
                )
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
                        .foregroundColor(hTextColor.Translucent.secondary)
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
        } else {
            ZStack {
                hText(" ", style: .body1)
                hText(conversation.timestamp.displayTimestamp, style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
            .transition(.scale.combined(with: .opacity))
            .matchedGeometryEffect(id: "rightView_\(conversation.id)", in: animationNamespace)
        }
    }

    @ViewBuilder
    private func getNewestMessage(for conversation: Conversation) -> some View {
        if let newestMessage = conversation.newestMessage {
            let color = getNewestMessageColor(for: conversation)
            MarkdownView(
                config: .init(
                    text: newestMessage.latestMessageText,
                    fontStyle: .label,
                    color: color,
                    linkColor: color,
                    linkUnderlineStyle: nil,
                    isSelectable: false,
                    maxLines: 1,
                    disableLinks: true,
                    onUrlClicked: { _ in
                    }
                )
            )
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
    @Published var processingState: ProcessingState = .loading
    private var hasFetchedOnce = false

    var isInboxEmpty: Bool {
        conversations.isEmpty && processingState == .success
    }
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

    func configureFetching() {
        pollTimerCancellable = nil
        Task {
            await fetchMessages()
        }
        pollTimerCancellable = Timer.publish(every: TimeInterval(5), on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                Task { [weak self] in
                    await self?.fetchMessages()
                }
            })
    }
    @MainActor
    func fetchMessages() async {
        do {
            if self.conversations.isEmpty && !hasFetchedOnce {
                withAnimation {
                    processingState = .loading
                }
            }
            let conversations = try await service.getConversations()
            hasFetchedOnce = true
            withAnimation {
                self.conversations = conversations
                self.processingState = .success
            }
        } catch {
            if self.conversations.isEmpty {
                hasFetchedOnce = false
                withAnimation {
                    pollTimerCancellable?.cancel()
                    processingState = .error(errorMessage: error.localizedDescription)
                }
            }
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
