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
    @PresentableStore private var store: ChatStore

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
                .padding(.bottom, 16)
        }
        .dismissKeyboard()
        .findScrollView({ sv in
            sv.delegate = chatScrollViewDelegate
        })
    }

    @ViewBuilder
    private var loadingPreviousMessages: some View {
        if vm.isFetchingNext {
            DotsActivityIndicator(.standard)
                .useDarkColor
                .fixedSize()
                .padding(.vertical, 8)
                .transition(.opacity)
        }
    }

    @ViewBuilder
    private func messagesContainer(with proxy: ScrollViewProxy?) -> some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(vm.messages, id: \.id) { message in
                    messageView(for: message)
                        .flippedUpsideDown()
                        .onAppear {
                            if message.id == vm.messages.last?.id {
                                Task {
                                    await vm.fetchNext()
                                }
                            }
                        }
                }
            }
            .padding([.horizontal, .bottom], 16)
            .padding(.top, vm.banner != nil ? 8 : 0)
            .onChange(of: vm.scrollToMessage?.id) { id in
                withAnimation {
                    proxy?.scrollTo(id, anchor: .bottom)
                }
            }
        }
        .flippedUpsideDown()
        .padding(.bottom, -8)
    }

    private func messageView(for message: Message) -> some View {
        HStack(alignment: .center, spacing: 0) {
            if message.sender == .member {
                Spacer()
            }
            VStack(alignment: message.sender == .hedvig ? .leading : .trailing, spacing: 4) {
                MessageView(message: message)
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
                        hCoreUIAssets.circularCheckmarkFilled.view
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(hSignalColor.blueElement)
                            .padding(.leading, 2)
                    } else if case .failed = message.status {
                        hText(L10n.chatFailedToSend)
                        hText(" ∙ \(message.timeStampString)")
                    } else {
                        hText(message.timeStampString)
                    }

                }
                .hTextStyle(.standardSmall)
                .foregroundColor(hTextColor.tertiary)
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
        if let banner = vm.banner {
            InfoCard(text: "", type: .info)
                .hInfoCardCustomView {
                    MarkdownView(
                        config: .init(
                            text: banner,
                            fontStyle: .standardSmall,
                            color: hSignalColor.blueText,
                            linkColor: hSignalColor.blueText,
                            linkUnderlineStyle: .single
                        ) { url in
                            store.send(.navigation(action: .linkClicked(url: url)))
                        }
                    )
                }
                .hInfoCardLayoutStyle(.rectange)
        }
    }
}

#Preview{
    let client = ChatDemoClient()
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
    return ChatScreen(vm: .init(topicType: nil))
}

class ChatScrollViewDelegate: NSObject, UIScrollViewDelegate, ObservableObject {
    let disposeBag = DisposeBag()
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let vc = scrollView.viewController
        vc?.isModalInPresentation = true
        setSheetInteractionState(vc: vc, to: false)
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let vc = scrollView.viewController
        vc?.isModalInPresentation = false
        setSheetInteractionState(vc: vc, to: true)
    }

    private func setSheetInteractionState(vc: UIViewController?, to: Bool) {
        let presentationController = vc?.navigationController?.presentationController ?? vc?.presentationController
        let key = [
            "_sheet", "Interaction",
        ]
        let sheetInteraction = presentationController?.value(forKey: key.joined()) as? NSObject
        sheetInteraction?.setValue(to, forKey: "enabled")
    }
}
