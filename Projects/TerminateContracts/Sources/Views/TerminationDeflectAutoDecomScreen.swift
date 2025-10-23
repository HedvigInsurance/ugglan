import SwiftUI
import hCore
import hCoreUI

struct TerminationDeflectAutoDecomScreen: View {
    @EnvironmentObject var router: Router
    let model: TerminationFlowDeflectAutoDecomModel
    init(model: TerminationFlowDeflectAutoDecomModel) {
        self.model = model
    }

    var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                hSection {
                    subtitleLabel(for: L10n.terminationFlowAutoDecomInfo)
                }
                hSection {
                    headerLabel(for: L10n.terminationFlowAutoDecomCoveredTitle)
                    subtitleLabel(for: L10n.terminationFlowAutoDecomCoveredInfo)
                }
                hSection {
                    headerLabel(for: L10n.terminationFlowAutoDecomCostsTitle)
                    subtitleLabel(for: L10n.terminationFlowAutoDecomCostsInfo)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, .padding16)
        }
        .hFormTitle(
            title: .init(
                .small,
                .heading2,
                L10n.terminationFlowAutoDecomTitle,
                alignment: .leading
            )
        )
        .hFormAlwaysAttachToBottom {
            hSection {
                VStack(spacing: .padding16) {
                    infoView
                    bottomButtons
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    private var infoView: some View {
        InfoCard(text: L10n.terminationFlowAutoDecomNotification, type: .info)
    }

    private var bottomButtons: some View {
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

    private func headerLabel(for text: String) -> some View {
        hText(text)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func subtitleLabel(for text: String) -> some View {
        hText(text)
            .foregroundColor(hTextColor.Translucent.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TerminationDeflectAutoDecomScreen_Previews: PreviewProvider {
    static var previews: some View {
        TerminationDeflectAutoDecomScreen(model: .init())
            .environmentObject(Router())
    }
}
