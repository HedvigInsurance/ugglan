import Combine
import PresentableStore
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import TagKit
import hCore
import hCoreUI

public struct InboxView: View {
    @StateObject var vm = InboxViewModel()
    @Namespace var animationNamespace
    @State var height: CGFloat = 0

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            ScrollableSegmentedView(vm: vm.scrollableSegmentedViewModel) { id in
                Group {
                    if id == "conversations" {
                        hForm {
                            displayMessages
                        }
                        .frame(height: proxy.size.height - 50)
                        .hSetScrollBounce(to: true)
                        .onPullToRefresh {
                            await vm.fetchMessages()

                        }
                    } else {
                        getMessagesView()
                            .hFormAlwaysAttachToBottom({
                                if !vm.emailMessages.isEmpty {

                                    hButton(.large, .primary, content: .init(title: "Filtrera")) {
                                        vm.showFilter = true
                                    }
                                    .padding(.horizontal, .padding16)
                                }
                            })
                            .frame(height: proxy.size.height - 50)
                            .hSetScrollBounce(to: true)
                            .onPullToRefresh {
                                await vm.fetchEmailMessages()
                            }
                    }
                }
            }
            .padding(.top, 8)
            .frame(maxHeight: .infinity, alignment: .top)
            .detent(item: $vm.documentPreviewId, style: [.large]) { id in
                let data = vm.emailMessages.first(where: { $0.id == id })!.body!.data(using: .utf8)!
                DocumentPreview(vm: DocumentPreviewModel(type: .data(data: data, mimeType: .HTML)))
            }
            .detent(presented: $vm.showFilter, style: [.height]) {
                hForm {
                    ListItems<String>(
                        onClick: { item in
                            vm.showSubFilter = true
                        },
                        items: ["Kategorier", "Datum"]
                            .compactMap({ (object: $0, displayName: $0) })

                    )
                    .hListRowStyle(.filled)
                }
                .hFormAttachToBottom {
                    hSection {
                        hCancelButton {
                            vm.showFilter = false
                        }
                        .padding(.vertical, .padding16)
                    }
                    .sectionContainerStyle(.transparent)
                }
                .configureTitle("Filtrera")
                .embededInNavigation(tracking: DocumentPreviewTrackingName.documentPreview)
                .hFormContentPosition(.compact)
            }
            .detent(presented: $vm.showSubFilter, style: [.height], options: .constant([.alwaysOpenOnTop])) {
                ItemPickerScreen<String>(
                    config: .init(
                        items: {
                            return vm.allFilters
                                .compactMap({ (object: $0, displayName: .init(title: $0)) })
                        }(),
                        preSelectedItems: {
                            return vm.selectedFilters
                        },
                        onSelected: { selectedDamages in
                            vm.showSubFilter = false
                            vm.showFilter = false
                            vm.selectedFilters = selectedDamages.compactMap({ $0.0 })
                        },
                        onCancel: {
                            vm.showSubFilter = false
                        }
                    )
                )
                .configureTitle("Filtrera efter kategori")
                .embededInNavigation(tracking: DocumentPreviewTrackingName.categoryFilter)
            }
        }
        .background {
            BackgroundView().ignoresSafeArea()
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

    private func getMessagesView() -> some View {
        VStack {
            if !vm.selectedFilters.isEmpty {
                hSection {
                    TagList(
                        tags: vm.selectedFilters,
                        horizontalSpacing: .padding6 / 2,
                        verticalSpacing: .padding6 / 2
                    ) { tag in
                        HStack(spacing: 2) {
                            hText(tag, style: .finePrint)
                            hCoreUIAssets.close.view
                                .resizable()
                                .frame(width: 12, height: 12)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(hHighlightColor.Blue.fillOne)
                        )
                        .onTapGesture {
                            withAnimation {
                                vm.selectedFilters.removeAll(where: { $0 == tag })
                            }
                        }

                    }
                }
                .sectionContainerStyle(.transparent)
            }
            hForm {
                hSection(vm.emailMessages) { message in
                    hRow {
                        VStack(alignment: .leading, spacing: .padding8) {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    hText(message.category ?? "", style: .body1)
                                    Spacer()
                                    ZStack {
                                        hText(" ", style: .body1)
                                        hText(message.createdAt!.displayTimeStamp, style: .label)
                                            .foregroundColor(hTextColor.Opaque.secondary)
                                    }

                                }
                                hText(message.subject ?? "", style: .label)
                                    .lineLimit(1)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(hTextColor.Translucent.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityAddTraits(.isButton)
                    }
                    .withEmptyAccessory
                    .onTap {
                        self.vm.documentPreviewId = message.id
                    }
                }
                .hWithoutHorizontalPadding([.section])
                .sectionContainerStyle(.transparent)
            }
            .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
                scrollView.clipsToBounds = true
            }
        }
        .loading($vm.emailMessagesLoadingState)
    }
}

enum DocumentPreviewTrackingName: TrackingViewNameProtocol {
    var nameForTracking: String {
        switch self {
        case .documentPreview:
            return String(describing: DocumentPreview.self)
        case .categoryFilter:
            return "Category filter"
        }

    }

    case documentPreview
    case categoryFilter

}

@MainActor
class InboxViewModel: ObservableObject {
    @Inject var service: ConversationsClient
    @Inject var emailsService: EmailMessagesClient
    @Published var documentPreviewId: String?
    @Published var showFilter: Bool = false
    @Published var showSubFilter: Bool = false
    @Published var selectedFilters: [String] = [] {
        didSet {
            withAnimation {
                if selectedFilters.isEmpty {
                    emailMessages = allMessages
                } else {
                    emailMessages = allMessages.filter({ selectedFilters.contains($0.category ?? "") })
                }
            }
        }
    }
    @Published var allFilters: [String] = []
    @Published var emailMessagesLoadingState: ProcessingState = .loading
    @Published var conversations: [Conversation] = []
    @Published var emailMessages: [EmailMessage] = []
    @Published var allMessages: [EmailMessage] = [] {
        didSet {
            withAnimation {
                if selectedFilters.isEmpty {
                    emailMessages = allMessages
                } else {
                    emailMessages = allMessages.filter({ selectedFilters.contains($0.category ?? "") })
                }
            }
        }
    }

    let scrollableSegmentedViewModel = ScrollableSegmentedViewModel(
        pageModels: [
            .init(id: "conversations", title: "Konversationer"),
            .init(id: "emails", title: "Meddelanden"),
        ],
        currentId: "conversations"
    )
    private var pollTimerCancellable: AnyCancellable?
    @PresentableStore var store: ChatStore
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
            [weak self] notification in
            Task {
                await self?.configureFetching()
            }
        }
        fetchMessages()
        Task {
            emailMessagesLoadingState = .loading
            await fetchEmailMessages()
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

    func fetchEmailMessages() async {
        do {
            let messages = try await self.emailsService.getEmailMessages()
            withAnimation {
                self.allMessages = messages
                self.allFilters = messages.compactMap({ $0.category }).unique(by: { $0 })
            }
            emailMessagesLoadingState = .success
        } catch {
            emailMessagesLoadingState = .error(errorMessage: error.localizedDescription)
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
            //TODO: EXCEPTION
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
    let emailMessagesClient = EmailMessagesClientDemo()
    let dateService = DateService()
    Dependencies.shared.add(module: Module { () -> DateService in dateService })
    Dependencies.shared.add(module: Module { () -> ConversationClient in client })
    Dependencies.shared.add(module: Module { () -> ConversationsClient in client })
    Dependencies.shared.add(module: Module { () -> EmailMessagesClient in emailMessagesClient })
    return InboxView()
}

extension Sequence {
    func unique<T: Hashable>(by keySelector: (Element) -> T) -> [Element] {
        var seen = Set<T>()
        return self.filter { element in
            let key = keySelector(element)
            return seen.insert(key).inserted
        }
    }
}
