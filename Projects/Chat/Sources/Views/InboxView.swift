import Combine
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct InboxView: View {
    @StateObject var vm = InboxViewModel()
    @Namespace var animationNamespace

    public init() {}

    public var body: some View {
        ScrollableSegmentedView(vm: vm.scrollVM) { id in
            if id == ConversationOpenStatus.open.rawValue {
                displayMessages(for: .open)
            } else {
                displayMessages(for: .closed)
            }
        }
        .padding(.top, .padding16)
        .background(
            hBackgroundColor.primary
        )
        .ignoresSafeArea(.all, edges: .bottom)
    }

    @ViewBuilder
    private func displayMessages(for status: ConversationOpenStatus) -> some View {
        hForm {
            hSection(vm.conversations[status] ?? []) { conversation in
                rowView(for: conversation, with: status)
                    .onTapGesture {
                        NotificationCenter.default.post(name: .openChat, object: conversation)
                    }
                    .background(getBackgroundColor(for: conversation))
            }
            .withoutHorizontalPadding
            .sectionContainerStyle(.transparent)
        }
        .onPullToRefresh {
            await vm.fetchMessages()
        }
        .background(Color.clear)
    }

    func rowView(for conversation: Conversation, with status: ConversationOpenStatus) -> some View {
        hRow {
            rowViewContent(for: conversation)
        }
        .shouldShowDivider(vm.shouldHideDivider(for: conversation, of: status))
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
    }

    @ViewBuilder
    private func getRightView(for conversation: Conversation) -> some View {
        if conversation.hasNewMessage {
            hText(L10n.chatNewMessage, style: .label)
                .foregroundColor(hTextColor.Opaque.black)
                .padding(.horizontal, .padding6)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(hHighlightColor.Blue.fillTwo)
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
                .foregroundColor(hTextColor.Translucent.secondary)
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
            hTextColor.Opaque.secondary
        }
    }
}

class InboxViewModel: ObservableObject {
    @Inject var service: ConversationsClient
    @Published var conversations: [ConversationOpenStatus: [Conversation]] = [:]

    private var pollTimerCancellable: AnyCancellable?
    @PresentableStore var store: ChatStore
    private var chatClosedObserver: NSObjectProtocol?
    @Published var scrollVM = ScrollableSegmentedViewModel(pageModels: [], fixedHeight: false)
    func shouldHideDivider(for conversation: Conversation, of conversationsStatus: ConversationOpenStatus) -> Bool {

        guard let conversations = self.conversations[conversationsStatus],
            let indexOfCurrent = conversations.firstIndex(where: { $0.id == conversation.id })
        else {
            return true
        }
        let indexOfNext = indexOfCurrent + 1
        guard indexOfNext < conversations.count else {
            return true
        }
        let currentConversation = conversations[indexOfCurrent]
        let nextConversation = conversations[indexOfNext]
        return currentConversation.hasNewMessage != nextConversation.hasNewMessage
        return true
    }

    init() {
        configureFetching()
        chatClosedObserver = NotificationCenter.default.addObserver(forName: .chatClosed, object: nil, queue: nil) {
            [weak self] notification in  //
            self?.configureFetching()
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
                let openedConversations = conversations.filter({ ($0.isConversationOpen ?? true) == true })
                let closedConversations = conversations.filter({ $0.isConversationOpen == false })
                var pageModels = [PageModel]()
                if !openedConversations.isEmpty {
                    pageModels.append(
                        .init(id: ConversationOpenStatus.open.rawValue, title: ConversationOpenStatus.open.title)
                    )
                }
                if !closedConversations.isEmpty {
                    pageModels.append(
                        .init(id: ConversationOpenStatus.closed.rawValue, title: ConversationOpenStatus.closed.title)
                    )
                }
                withAnimation {
                    self.conversations[.open] = openedConversations
                    self.conversations[.closed] = closedConversations
                    scrollVM.update(pageModels: pageModels)
                }
            }
        } catch _ {
            //TODO: EXCEPTION
        }
    }

    deinit {
        if let chatClosedObserver {
            NotificationCenter.default.removeObserver(chatClosedObserver)
        }
    }
}

#Preview{
    Dependencies.shared.add(module: Module { () -> ConversationClient in ConversationDemoClient() })
    Dependencies.shared.add(module: Module { () -> ConversationsClient in ConversationsDemoClient() })
    return InboxView()
}
