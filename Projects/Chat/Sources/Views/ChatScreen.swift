import Combine
import SwiftUI
import hCore
import hCoreUI

public struct ChatScreen: View {
    @StateObject var vm: ChatScreenViewModel
    @ObservedObject var conversationVm: ChatConversationViewModel
    @ObservedObject var messageVm: ChatMessageViewModel

    @State var infoViewHeight: CGFloat = 0
    @State var infoViewWidth: CGFloat = 0
    @StateObject var chatScrollViewDelegate = ChatScrollViewDelegate()
    @EnvironmentObject var chatNavigationVm: ChatNavigationViewModel
    @State private var isTargetedForDropdown = false
    public init(
        vm: ChatScreenViewModel
    ) {
        _vm = StateObject(wrappedValue: vm)
        messageVm = vm.messageVm
        conversationVm = vm.messageVm.conversationVm
    }

    public var body: some View {
        ScrollViewReader { proxy in
            loadingPreviousMessages
            messagesContainer(with: proxy)
                .flippedUpsideDown()
                .padding(.bottom, -8)
            infoCard
                .padding(.bottom, -8)
            ChatInputView(vm: vm.chatInputVm)
                .padding(.bottom, .padding16)
                .layoutPriority(1)
        }
        .modifier(
            ChatScreenModifier(
                vm: vm,
                messageVm: messageVm,
                conversationVm: conversationVm,
                chatScrollViewDelegate: chatScrollViewDelegate,
                isTargetedForDropdown: $isTargetedForDropdown
            )
        )
    }

    @ViewBuilder
    private var loadingPreviousMessages: some View {
        if messageVm.isFetchingPreviousMessages {
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
            LazyVStack(spacing: .padding8) {
                let messages = messageVm.messages
                ForEach(messages) { message in
                    messageView(for: message, conversationStatus: conversationVm.conversationStatus)
                        .flippedUpsideDown()
                        .onAppear {
                            if message.id == messageVm.messages.last?.id {
                                Task {
                                    await messageVm.fetchPreviousMessages()
                                }
                            }
                        }
                }
            }
            .padding([.horizontal, .bottom], .padding16)
            .padding(.top, conversationVm.banner != nil ? .padding8 : 0)
            .onChange(of: messageVm.scrollToMessage?.id) { id in
                withAnimation {
                    proxy?.scrollTo(id, anchor: .bottom)
                }
            }
        }
    }

    private func messageView(for message: Message, conversationStatus: ConversationStatus) -> some View {
        VStack(spacing: .padding16) {
            HStack(alignment: .center, spacing: 0) {
                if message.sender == .member {
                    Spacer()
                }
                VStack(alignment: message.sender.alignment.horizontal, spacing: .padding4) {
                    MessageView(message: message, conversationStatus: conversationStatus, vm: vm)

                    messageTimeStamp(message: message)
                        .accessibilityHidden(true)
                }
                if message.sender == .hedvig || message.sender == .automation {
                    Spacer()
                }
            }
            .id(message.id)

            if let disclaimer = message.disclaimer {
                automationBanner(disclaimer: disclaimer)
            }
        }
    }

    @ViewBuilder
    private func automationBanner(disclaimer: MessageDisclaimer) -> some View {
        if let title = disclaimer.title, let description = disclaimer.description {
            InfoCard(
                title: title,
                text: description,
                type: disclaimer.type == .information ? .neutral : .escalation
            )
            .buttons(
                buttons(for: disclaimer)
            )
        }
    }

    private func buttons(for disclaimer: MessageDisclaimer) -> [InfoCardButtonConfig] {
        if let detailsDescription = disclaimer.detailsDescription {
            return [
                .init(
                    buttonTitle: L10n.automatedMessageInfoCardButton,
                    buttonAction: { [weak chatNavigationVm] in
                        chatNavigationVm?.isAutomationMessagePresented = .init(
                            title: disclaimer.detailsTitle,
                            description: detailsDescription
                        )
                    }
                )
            ]
        } else {
            return []
        }
    }

    private func messageTimeStamp(message: Message) -> some View {
        HStack(spacing: 0) {
            if messageVm.lastDeliveredMessage?.id == message.id {
                hText(message.timeStampString)
                hText(" ∙ \(L10n.chatDeliveredMessage)")
                hCoreUIAssets.checkmarkFilled.view
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(hSignalColor.Blue.element)
                    .padding(.leading, .padding2)
            } else if case .failed = message.status {
                hText(L10n.chatFailedToSend)
                hText(" ∙ \(message.timeStampString)")
            } else {
                if message.sender == .automation {
                    hText("\(L10n.chatSenderAutomation) ∙ ")
                }
                hText(message.timeStampString)
            }
        }
        .hTextStyle(.label)
        .foregroundColor(hTextColor.Opaque.secondary)
        .padding(.bottom, 3)
    }

    @ViewBuilder
    private var infoCard: some View {
        if conversationVm.shouldShowBanner {
            if let banner = conversationVm.banner {
                InfoCard(text: "", type: .info)
                    .hInfoCardCustomView {
                        MarkdownView(
                            config: .init(
                                text: (conversationVm.conversationStatus == .closed)
                                    ? L10n.chatConversationClosedInfo : banner,
                                fontStyle: .label,
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

struct ChatScreenModifier: ViewModifier {
    @ObservedObject var vm: ChatScreenViewModel
    @ObservedObject var messageVm: ChatMessageViewModel
    @ObservedObject var conversationVm: ChatConversationViewModel
    @ObservedObject var chatScrollViewDelegate: ChatScrollViewDelegate
    @EnvironmentObject var chatNavigationVm: ChatNavigationViewModel
    @Binding var isTargetedForDropdown: Bool

    func body(content: Content) -> some View {
        content
            .dismissKeyboard()
            .findScrollView { sv in
                sv.delegate = chatScrollViewDelegate
                //TODO: REDO after iOS 26
                //                if #available(iOS 26.0, *) {
                //                    sv.topEdgeEffect.isHidden = true
                //                }
            }
            .task {
                messageVm.chatNavigationVm = chatNavigationVm
            }
            .configureTitleView(
                title: conversationVm.title,
                subTitle: conversationVm.subTitle,
                onTitleTap: { [weak conversationVm, weak chatNavigationVm] in
                    if let claimId = conversationVm?.claimId {
                        chatNavigationVm?.showClaimDetail(claimId: claimId)
                    }
                }
            )
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
            .fileDrop(isTargetedForDropdown: $isTargetedForDropdown) { file in
                Task {
                    let message = Message(type: .file(file: file))
                    await messageVm.send(message: message)
                }
            }
    }
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
        withVelocity _: CGPoint,
        targetContentOffset _: UnsafeMutablePointer<CGPoint>
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
                    if vc.presentationController is BlurredSheetPresenationController {
                        return vc
                    } else if let superviewVc = vc.view.superview?.viewController {
                        return findProverVC(from: superviewVc)
                    } else if let parent = vc.parent {
                        return findProverVC(from: parent)
                    }
                }
            }
        } else {
            return vc?.navigationController?.view.superview?.viewController ?? vc
        }
        return nil
    }
}

extension MessageSender {
    var alignment: Alignment {
        switch self {
        case .member: return .trailing
        case .hedvig, .automation: return .leading
        }
    }
}
