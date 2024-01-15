import Combine
import Flow
import Form
import SwiftUI
import hCore
import hCoreUI

struct ChatScreen: View {
    @StateObject var vm: ChatScreenViewModel

    var body: some View {
        VStack {
            loadingPreviousMessages
            ScrollViewReader { proxy in
                messagesContainer(with: proxy)
                ChatInputView(vm: vm.chatInputVm)
            }
            .padding()
            .dismissKeyboard()
        }
    }

    @ViewBuilder
    private var loadingPreviousMessages: some View {
        if vm.isFetchingNext {
            DotsActivityIndicator(.standard)
                .useDarkColor
                .fixedSize()
                .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private func messagesContainer(with proxy: ScrollViewProxy) -> some View {
        ScrollView {
            LazyVStack {
                ForEach(vm.messages, id: \.self) { message in
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
            .onAppear {
                withAnimation {
                    proxy.scrollTo(vm.messages.last, anchor: .bottom)
                }
            }
            .onChange(of: vm.scrollToMessage) { message in
                withAnimation {
                    proxy.scrollTo(message, anchor: .bottom)
                }
            }
        }
        .flippedUpsideDown()
        //            .introspectScrollView { scrollView in
        //                scrollView.viewController?.isModalInPresentation = true
        //                let presentationController = scrollView.viewController?.navigationController?.presentationController
        //                let key = [
        //                    "_sheet", "Interaction",
        //                ]
        //                let sheetInteraction = presentationController?.value(forKey: key.joined()) as? NSObject
        //                sheetInteraction?.setValue(true, forKey: "enabled")
        ////                scrollView.viewController?.sheet
        //                // hack to fix modal dismissing when dragging up in scrollView
        ////                let bag = DisposeBag()
        ////                print("DELEGATE IS \(scrollView.delegate)")
        ////                func setSheetInteractionState(_ enabled: Bool) {
        ////                    let presentationController = scrollView.viewController?.navigationController?.presentationController
        ////                    let key = [
        ////                        "_sheet", "Interaction",
        ////                    ]
        ////                    let sheetInteraction = presentationController?.value(forKey: key.joined()) as? NSObject
        ////                    sheetInteraction?.setValue(enabled, forKey: "enabled")
        ////                }
        ////                scrollView.signal
        ////                bag += scrollView.delegate.willBeginDragging.onValue { _ in
        ////                    scrollView.viewController?.isModalInPresentation = true
        ////                    setSheetInteractionState(false)
        ////                }
        ////
        ////                bag += scrollView.delegate.willEndDragging.onValue { _ in
        ////                    scrollView.viewController.isModalInPresentation = false
        ////                    setSheetInteractionState(true)
        ////                }
        //            }
    }

    private func messageView(for message: Message) -> some View {
        HStack(alignment: .center, spacing: 0) {
            if message.sender == .member {
                Spacer()
            }
            VStack(alignment: message.sender == .hedvig ? .leading : .trailing, spacing: 0) {
                message
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
                    } else if case .failed = message.status {
                        hText(L10n.chatFailedToSend)
                        hText(" ∙ \(message.timeStampString)")
                    } else {
                        hText(message.timeStampString)
                    }

                }
                .hTextStyle(.standardSmall)
                .foregroundColor(hTextColor.tertiary)
            }
            if message.sender == .hedvig {
                Spacer()
            }
        }
        .id(message.id)
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
    return ChatScreen(vm: .init())
}
