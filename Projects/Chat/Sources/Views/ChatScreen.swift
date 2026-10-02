import Combine
import SwiftUI
import hCore
import hCoreUI

public struct ChatScreen: View {
    @ObservedObject var vm: ChatScreenViewModel
    @ObservedObject var conversationVm: ChatConversationViewModel
    @ObservedObject var messageVm: ChatMessageViewModel
    @ObservedObject var crossSellVm: ChatCrossSellViewModel
    @StateObject var chatScrollViewDelegate = ChatScrollViewDelegate()
    @EnvironmentObject var chatNavigationVm: ChatNavigationViewModel
    @State private var isTargetedForDropdown = false
    @AccessibilityFocusState private var isChatInputFocused: Bool
    public init(
        vm: ChatScreenViewModel
    ) {
        self.vm = vm
        messageVm = vm.messageVm
        conversationVm = vm.messageVm.conversationVm
        crossSellVm = vm.messageVm.crossSellVm
    }

    public var body: some View {
        ScrollViewReader { proxy in
            loadingPreviousMessages
            messagesContainer(with: proxy)
                .flippedUpsideDown()
                .padding(.bottom, -8)
            bottomBanner
                .padding(.bottom, -8)
            ChatInputView(vm: vm.chatInputVm, a11yFocus: $isChatInputFocused)
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
        .trackVisibility(as: ChatScreen.self)
        .onChange(of: crossSellVm.recommended?.id) { id in
            // Answering the prompt removes the button that VoiceOver is focused on, which
            // would otherwise throw focus back to the top of the conversation with no
            // confirmation that the tap did anything. Guarding on nil keeps the banner
            // appearing from stealing focus.
            if id == nil {
                isChatInputFocused = true
            } else {
                // Nothing in the layout moves when a poll inserts the prompt, so VoiceOver
                // would stay silent on a card the member can act on. The wait lets the
                // insertion settle -- an announcement posted into it is dropped, not queued.
                let announcement = crossSellVm.voiceOverAnnouncement
                Task {
                    await delay(0.25)
                    UIAccessibility.post(notification: .announcement, argument: announcement)
                }
            }
        }
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
            LazyVStack(spacing: .padding16) {
                if messageVm.responseIsBeingGenerated {
                    HStack {
                        DotsActivityIndicator(.standard)
                            .colorScheme(.dark)
                            .padding(.padding10)
                            .background(hSurfaceColor.Opaque.primary)
                            .clipShape(Capsule())
                        Spacer()
                    }
                }
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
            .padding([.horizontal, .vertical], .padding16)
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

    private func automationBanner(disclaimer: MessageDisclaimer) -> some View {
        InfoCard(
            title: disclaimer.title,
            text: disclaimer.description,
            type: disclaimer.type == .information ? .neutral : .escalation
        )
        .buttons(
            buttons(for: disclaimer)
        )
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
                } else if message == messageVm.firstHedvigMessageAfterAutomation {
                    hText("\(L10n.chatSenderHedvig) ∙ ")
                }
                hText(message.timeStampString)
            }
        }
        .hTextStyle(.label)
        .foregroundColor(hTextColor.Opaque.secondary)
    }

    // Three independent elements share the slot above the input. An offer takes the slot
    // away from the status message, but sits alongside the closed notice, which tells the
    // member nobody will reply. All three hide while the keyboard is up; the offer and the
    // closed notice come back when it is dismissed, while the status message rides on
    // `shouldShowBanner`, which latches off for the session.
    //
    // offer | status | closed | shows               | after keyboard open/close
    // ------+--------+--------+---------------------+--------------------------
    //   -   |   -    |   -    | nothing             | nothing
    //   -   |   x    |   -    | Info                | nothing
    //   -   |   -    |   x    | ClosedInfo          | ClosedInfo
    //   -   |   x    |   x    | ClosedInfo          | ClosedInfo
    //   x   |   -    |   -    | Banner              | Banner
    //   x   |   x    |   -    | Banner              | Banner
    //   x   |   -    |   x    | Banner + ClosedInfo | Banner + ClosedInfo
    //   x   |   x    |   x    | Banner + ClosedInfo | Banner + ClosedInfo
    //
    // Each element is its own conditional rather than a branch of one `if`, so SwiftUI
    // keeps their identities separate and can transition one without reinserting another.
    @ViewBuilder
    private var bottomBanner: some View {
        VStack(spacing: 0) {
            if showsCrossSell {
                hSection {
                    ChatCrossSellBanner(vm: crossSellVm)
                }
                .sectionContainerStyle(.transparent)
                .padding(.bottom, .padding16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            if showsClosedInfo {
                infoCard(text: L10n.chatConversationClosedInfo)
            }
            if showsStatusInfo, let banner = conversationVm.banner {
                infoCard(text: banner)
            }
        }
        .animation(.spring, value: showsCrossSell)
        .animation(.spring, value: showsClosedInfo)
        .animation(.spring, value: showsStatusInfo)

        .frame(maxWidth: .infinity)
    }

    private var showsCrossSell: Bool {
        crossSellVm.recommended != nil && !conversationVm.isKeyboardShown
    }

    private var showsClosedInfo: Bool {
        conversationVm.conversationStatus == .closed && !conversationVm.isKeyboardShown
    }

    private var showsStatusInfo: Bool {
        crossSellVm.recommended == nil
            && conversationVm.conversationStatus != .closed
            && conversationVm.shouldShowBanner
    }

    private func infoCard(text: Markdown) -> some View {
        InfoCard(text: "", type: .info)
            .hInfoCardCustomView {
                MarkdownView(
                    config: .init(
                        text: text,
                        fontStyle: .label,
                        color: hSignalColor.Blue.text,
                        linkColor: hSignalColor.Blue.text,
                        linkUnderlineStyle: .single,
                        isSelectable: false
                    ) { url in
                        NotificationCenter.default.post(name: .openDeepLink, object: url)
                    }
                )
            }
            .hInfoCardLayoutStyle(.bannerStyle)
            .transition(.opacity)
    }
}

struct ChatScreenModifier: ViewModifier {
    @ObservedObject var vm: ChatScreenViewModel
    @ObservedObject var messageVm: ChatMessageViewModel
    @ObservedObject var conversationVm: ChatConversationViewModel
    @ObservedObject var chatScrollViewDelegate: ChatScrollViewDelegate
    @EnvironmentObject var chatNavigationVm: ChatNavigationViewModel
    @Binding var isTargetedForDropdown: Bool
    @State private var showSubtitle = false
    func body(content: Content) -> some View {
        content
            .dismissKeyboard()
            .findScrollView { sv in
                sv.delegate = chatScrollViewDelegate
                if #available(iOS 26.0, *) {
                    sv.topEdgeEffect.isHidden = true
                }
            }
            .task {
                messageVm.chatNavigationVm = chatNavigationVm
            }
            .configureTitleView(
                title: conversationVm.title,
                subTitle: showSubtitle ? conversationVm.subTitle : " ",
                onTitleTap: { [weak conversationVm, weak chatNavigationVm] in
                    if let claimId = conversationVm?.claimId {
                        chatNavigationVm?.showClaimDetail(claimId: claimId)
                    }
                }
            )
            .onAppear {
                vm.observeScrolling(chatScrollViewDelegate.isScrolling)
                Task {
                    await vm.startFetchingNewMessages()
                }
            }
            .task {
                await delay(0.4)
                showSubtitle = true
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
            sheetInteraction?.setValue(to, forKey: "enabled")
        }
    }

    private func findProverVC(from vc: UIViewController?) -> UIViewController? {
        if let vc {
            if let navigation = vc.navigationController {
                return findProverVC(from: navigation)
            } else {
                if vc.presentationController is BlurredSheetPresentationController {
                    return vc
                } else if let superviewVc = vc.view.superview?.viewController {
                    return findProverVC(from: superviewVc)
                } else if let parent = vc.parent {
                    return findProverVC(from: parent)
                }
            }
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
