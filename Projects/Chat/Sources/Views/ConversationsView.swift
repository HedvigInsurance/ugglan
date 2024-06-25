import SwiftUI
import hCore
import hCoreUI

public struct ConversationsView: View {
    @StateObject var vm = ConversationsViewModel()

    public init() {}

    public var body: some View {
        hForm {
            displayMessages
        }
    }

    @ViewBuilder
    var displayMessages: some View {
        hSection(vm.conversations) { conversation in
            HStack {
                if conversation.type == .legacy {
                    hRow {
                        HStack(spacing: 16) {
                            Image(uiImage: hCoreUIAssets.activeInbox.image)
                                .resizable()
                                .frame(width: 10, height: 9)
                                .foregroundColor(hFillColor.Opaque.secondary)
                            hText("Conversation history until " + Date().localDateString, style: .footnote)
                        }
                    }
                } else {
                    hRow {
                        HStack {
                            Circle()
                                .frame(width: 8)
                                .foregroundColor(hSignalColor.Red.element)
                                .frame(maxHeight: .infinity, alignment: .top)
                                .padding(.top, 8)

                            VStack(alignment: .leading, spacing: 4) {
                                hText(conversation.title, style: .body)
                                HStack(spacing: 8) {
                                    hText(conversation.subtitle ?? "", style: .footnote)
                                    hText("|")
                                        .foregroundColor(hBorderColor.secondary)
                                    hText("Submitted " + (conversation.createdAt ?? ""), style: .footnote)
                                }
                                .foregroundColor(hTextColor.Opaque.accordion)

                                if let newestMessage = conversation.newestMessage {
                                    switch newestMessage.type {
                                    case let .text(text):
                                        hText(text, style: .footnote)
                                            .padding(.top, 4)
                                    default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .onTapGesture {
                NotificationCenter.default.post(name: .openChat, object: conversation)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

class ConversationsViewModel: ObservableObject {
    @Inject var service: ConversationsClient
    @Published var conversations: [Conversation] = []

    init() {
        Task { @MainActor in
            self.conversations = try await service.getConversations()
        }
    }
}

#Preview{
    Dependencies.shared.add(module: Module { () -> ConversationClient in ConversationDemoClient() })
    return ConversationsView()
}
