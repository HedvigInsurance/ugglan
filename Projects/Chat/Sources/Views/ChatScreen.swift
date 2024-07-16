import Combine
import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ChatScreen: View {
    @StateObject var vm: ChatScreenViewModel
    @State var infoViewHeight: CGFloat = 0
    @State var infoViewWidth: CGFloat = 0
    @StateObject var chatScrollViewDelegate = ChatScrollViewDelegate()
    @EnvironmentObject var chatNavigationVm: ChatNavigationViewModel
    public init(
        vm: ChatScreenViewModel
    ) {
        self._vm = StateObject(wrappedValue: vm)
    }

    public var body: some View {
        ScrollViewReader { proxy in
            loadingPreviousMessages
            messagesContainer(with: proxy)
            infoCard
                .padding(.bottom, -8)
            ChatInputView(vm: vm.chatInputVm)
                .padding(.bottom, .padding16)
        }
        .dismissKeyboard()
        .findScrollView({ sv in
            sv.delegate = chatScrollViewDelegate
        })
        .task {
            vm.chatNavigationVm = chatNavigationVm
        }
        .configureTitleView(vm)
        .onAppear {
            vm.scrollCancellable = chatScrollViewDelegate.isScrolling
                .subscribe(on: RunLoop.main)
                .sink { [weak vm] _ in
                    withAnimation {
                        vm?.chatInputVm.showBottomMenu = false
                    }
                }
            Task {
                await vm.startFetchingNewMessages()
            }
        }
    }

    @ViewBuilder
    private var loadingPreviousMessages: some View {
        if vm.isFetchingPreviousMessages {
            DotsActivityIndicator(.standard)
                .useDarkColor
                .fixedSize()
                .padding(.vertical, .padding8)
                .transition(.opacity)
        }
    }

    @ViewBuilder
    private func messagesContainer(with proxy: ScrollViewProxy?) -> some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(vm.messages) { message in
                    messageView(for: message, isConversationOpen: vm.isConversationOpen)
                        .flippedUpsideDown()
                        .onAppear {
                            if message.id == vm.messages.last?.id {
                                Task {
                                    await vm.fetchPreviousMessages()
                                }
                            }
                        }
                }
            }
            .padding([.horizontal, .bottom], .padding16)
            .padding(.top, vm.banner != nil ? .padding8 : 0)
            .onChange(of: vm.scrollToMessage?.id) { id in
                withAnimation {
                    proxy?.scrollTo(id, anchor: .bottom)
                }
            }
        }
        .flippedUpsideDown()
        .padding(.bottom, -8)
    }

    private func messageView(for message: Message, isConversationOpen: Bool) -> some View {
        HStack(alignment: .center, spacing: 0) {
            if message.sender == .member {
                Spacer()
            }
            VStack(alignment: message.sender == .hedvig ? .leading : .trailing, spacing: 4) {
                MessageView(message: message, isConversationOpen: isConversationOpen)
                    .frame(
                        maxWidth: 300,
                        alignment: message.sender == .member ? .trailing : .leading
                    )
                    .foregroundColor(message.textColor)
                    .onTapGesture {
                        if case .failed = message.status {
                            Task {
                                await vm.retrySending(message: message)
                            }
                        }
                    }
                HStack(spacing: 0) {
                    if vm.lastDeliveredMessage?.id == message.id {
                        hText(message.timeStampString)
                        hText(" ∙ \(L10n.chatDeliveredMessage)")
                        hCoreUIAssets.checkmarkFilled.view
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(hSignalColor.Blue.element)
                            .padding(.leading, 2)
                    } else if case .failed = message.status {
                        hText(L10n.chatFailedToSend)
                        hText(" ∙ \(message.timeStampString)")
                    } else {
                        hText(message.timeStampString)
                    }

                }
                .hTextStyle(.label)
                .foregroundColor(hTextColor.Opaque.secondary)
                .padding(.bottom, 3)

            }
            if message.sender == .hedvig {
                Spacer()
            }
        }
        .id(message.id)
    }

    @ViewBuilder
    private var infoCard: some View {
        if vm.shouldShowBanner {
            if let banner = vm.banner {
                InfoCard(text: "", type: .info)
                    .hInfoCardCustomView {
                        MarkdownView(
                            config: .init(
                                text: !vm.isConversationOpen ? L10n.chatConversationClosedInfo : banner,
                                fontStyle: .standardSmall,
                                color: hSignalColor.Blue.text,
                                linkColor: hSignalColor.Blue.text,
                                linkUnderlineStyle: .single
                            ) { url in
                                NotificationCenter.default.post(name: .openDeepLink, object: url)
                            }
                        )
                    }
                    .hInfoCardLayoutStyle(.bannerStyle)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

#Preview{
    let client = ChatDemoClient()
    let conversationClient = ConversationDemoClient()
    Dependencies.shared.add(
        module: Module { () -> FetchMessagesClient in
            client
        }
    )
    Dependencies.shared.add(
        module: Module { () -> SendMessageClient in
            client
        }
    )
    return ChatScreen(vm: .init(chatService: MessagesService(topic: nil))).environmentObject(ChatNavigationViewModel())
}

class ChatScrollViewDelegate: NSObject, UIScrollViewDelegate, ObservableObject {

    let isScrolling = PassthroughSubject<Bool, Never>()

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling.send(true)
        let vc = findProverVC(from: scrollView.viewController)
        vc?.isModalInPresentation = true
        vc?.navigationController?.isModalInPresentation = true
        setSheetInteractionState(vc: vc, to: false)
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        isScrolling.send(false)
        let vc = findProverVC(from: scrollView.viewController)
        vc?.isModalInPresentation = false
        vc?.navigationController?.isModalInPresentation = false
        setSheetInteractionState(vc: vc, to: true)
    }

    private func setSheetInteractionState(vc: UIViewController?, to: Bool) {
        if let presentationController = vc?.presentationController as? UISheetPresentationController {
            let key = [
                "_sheet", "Interaction",
            ]
            let sheetInteraction = presentationController.value(forKey: key.joined()) as? NSObject
            print("SET FOR \(vc!) to \(to) - \(sheetInteraction!)")
            sheetInteraction?.setValue(to, forKey: "enabled")
        }
    }

    private func findProverVC(from vc: UIViewController?) -> UIViewController? {
        if #available(iOS 16.0, *) {
            if let vc {
                if let navigation = vc.navigationController {
                    return findProverVC(from: navigation)
                } else {
                    if let vccc = vc.presentationController as? BlurredSheetPresenationController {
                        return vc
                    } else if let superviewVc = vc.view.superview?.viewController {
                        return findProverVC(from: superviewVc)
                    }
                }
            }
        } else {
            return vc?.navigationController?.view.superview?.viewController ?? vc
        }
        return nil
    }
}
