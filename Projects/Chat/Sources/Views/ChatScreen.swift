import Combine
import Flow
import Form
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ChatScreen: View {
    @StateObject var vm: ChatScreenViewModel
    @State var infoViewHeight: CGFloat = 0
    @State var infoViewWidth: CGFloat = 0

    @PresentableStore private var store: ChatStore
    var body: some View {
        ScrollViewReader { proxy in
            loadingPreviousMessages
            messagesContainer(with: proxy)
            infoCard
                .padding(.bottom, -8)
            ChatInputView(vm: vm.chatInputVm)
                .padding(.bottom, 32)
        }
        .dismissKeyboard()
        .edgesIgnoringSafeArea(.bottom)
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
        .introspectViewController { vc in
            vc.isModalInPresentation = true
            let presentationController = vc.navigationController?.presentationController
            let key = [
                "_sheet", "Interaction",
            ]
            let sheetInteraction = presentationController?.value(forKey: key.joined()) as? NSObject
            sheetInteraction?.setValue(false, forKey: "enabled")
        }
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
                    GeometryReader { geo in
                        if infoViewWidth > 0 {
                            hCoreUI.CustomTextViewRepresentable(
                                config: .init(
                                    text: banner,
                                    fixedWidth: infoViewWidth,
                                    fontStyle: .standardSmall,
                                    color: hSignalColor.blueText,
                                    linkColor: hSignalColor.blueText,
                                    linkUnderlineStyle: .single,
                                    onUrlClicked: { url in
                                        store.send(.navigation(action: .linkClicked(url: url)))
                                    }
                                ),
                                height: $infoViewHeight
                            )
                        } else {
                            Rectangle().frame(height: 0)
                                .onReceive(Just(geo.size.width)) { width in
                                    self.infoViewWidth = width
                                }
                        }
                    }
                    .frame(height: infoViewHeight)

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
