import SwiftUI
import hCore
import hCoreUI

struct TerminationDeflectAutoCancelScreen: View {
    @EnvironmentObject var router: Router
    let model: TerminationFlowDeflectAutoCancelModel
    init(model: TerminationFlowDeflectAutoCancelModel) {
        self.model = model
    }

    var body: some View {
        hForm {
            hSection {
                hText(model.message)
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, .padding16)
        }
        .hFormTitle(
            title: .init(
                .small,
                .heading2,
                L10n.terminationFlowAutoCancelTitle,
                alignment: .leading
            )
        )
        .hFormAlwaysAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hButton(
                        .large,
                        .primary,
                        content: .init(title: L10n.terminationFlowIUnderstandText)
                    ) { [weak router] in
                        router?.dismiss()
                    }

                    hButton(
                        .large,
                        .ghost,
                        content: .init(title: L10n.CrossSell.Info.faqChatButton)
                    ) {
                        NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

struct TerminationDeflectAutoCancelScreen_Previews: PreviewProvider {
    static var previews: some View {
        TerminationDeflectAutoCancelScreen(model: .init(message: "test message"))
            .environmentObject(Router())
    }
}
