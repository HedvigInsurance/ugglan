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
                .transition(.opacity)
        }
    }

    @ViewBuilder
    private func messagesContainer(with proxy: ScrollViewProxy) -> some View {
        ScrollView {
            LazyVStack {
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
            .padding([.horizontal, .top], 16)
            .onChange(of: vm.scrollToMessage?.id) { id in
                withAnimation {
                    proxy.scrollTo(id, anchor: .bottom)
                }
            }
        }
        .flippedUpsideDown()
        .introspectViewController { vc in
            vc.isModalInPresentation = true
            let presentationController = vc.navigationController?.presentationController
            let key = [
                "_sheet", "Interaction",
            ]
            let sheetInteraction = presentationController?.value(forKey: key.joined()) as? NSObject
            sheetInteraction?.setValue(false, forKey: "enabled")
        }
        .introspectScrollView { scrollView in
            scrollView.bounces = false
        }
    }

    private func messageView(for message: Message) -> some View {
        HStack(alignment: .center, spacing: 0) {
            if message.sender == .member {
                Spacer()
            }
            VStack(alignment: message.sender == .hedvig ? .leading : .trailing, spacing: 0) {
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
