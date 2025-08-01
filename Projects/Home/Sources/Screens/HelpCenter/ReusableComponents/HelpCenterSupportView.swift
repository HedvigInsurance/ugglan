import hCore
import hCoreUI
import PresentableStore
import SwiftUI

struct SupportView: View {
    @PresentableStore var store: HomeStore
    @ObservedObject var router: Router
    @Environment(\.sizeCategory) private var sizeCategory
    let withExtraPadding: Bool

    init(
        router: Router,
        withExtraPadding: Bool? = false
    ) {
        self.router = router
        self.withExtraPadding = withExtraPadding ?? false
    }

    var body: some View {
        hSection {
            VStack(spacing: .padding40) {
                textView
                buttonView
            }
            .padding(.top, .padding32)
            .padding(.bottom, .padding8)
        }
        .hWithoutHorizontalPadding([.section])
        .sectionContainerCornerMaskerCorners([.topLeft, .topRight])
    }

    private var textView: some View {
        VStack(spacing: .padding16) {
            hCoreUIAssets.infoFilled.view
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(hSignalColor.Blue.element)
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                hText(L10n.hcChatQuestion)
                    .accessibilityAddTraits(.isHeader)
                hText(L10n.hcChatAnswer)
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, .padding32)
        }
    }

    private var buttonView: some View {
        PresentableStoreLens(HomeStore.self) { state in
            state.hasSentOrRecievedAtLeastOneMessage
        } _: { hasSentOrRecievedAtLeastOneMessage in
            hRow {
                HStack(spacing: .padding4) {
                    hButton(
                        .medium,
                        .secondary,
                        content: .init(title: L10n.newMessageButton)
                    ) {
                        NotificationCenter.default.post(
                            name: .openChat,
                            object: ChatType.newConversation
                        )
                    }

                    if hasSentOrRecievedAtLeastOneMessage {
                        hButton(
                            .medium,
                            .primary,
                            content: .init(title: L10n.hcChatGoToInbox)
                        ) {
                            router.push(HelpCenterNavigationRouterType.inbox)
                        }
                    }
                }
                .hButtonTakeFullWidth(true)
            }
            .verticalPadding(0)
        }
        .presentableStoreLensAnimation(.default)
    }
}

#Preview {
    SupportView(router: Router())
}
