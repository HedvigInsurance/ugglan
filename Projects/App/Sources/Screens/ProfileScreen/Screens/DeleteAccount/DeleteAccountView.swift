import SwiftUI
import hCore
import hCoreUI

struct DeleteAccountView: View {
    @ObservedObject var viewModel: DeleteAccountViewModel

    var body: some View {
        if viewModel.hasActiveClaims || viewModel.hasActiveContracts {
            BlockAccountDeletionView()
        } else {
            hForm {
                hText(L10n.DeleteAccount.confirmationTitle, style: .title2)
                    .foregroundColor(hLabelColor.primary)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)

                hSection {
                    hText(L10n.DeleteAccount.deletedDataDescription, style: .callout)
                        .modifier(ParagraphTextModifier(color: hLabelColor.secondary))
                        .padding(16)
                }

                hSection {
                    hText(L10n.DeleteAccount.processingFooter, style: .callout)
                        .modifier(ParagraphTextModifier(color: hLabelColor.secondary))
                        .padding(16)
                }
            }
            .hFormAttachToBottom {
                VStack {
                    Button {
                        viewModel.deleteAccount()
                    } label: {
                        hText(L10n.DeleteAccount.confirmButton, style: .body)
                            .foregroundColor(.white)
                            .frame(minHeight: 52)
                            .frame(minWidth: 200)
                            .frame(maxWidth: .infinity)
                    }
                    .background(hTintColor.red)
                    .cornerRadius(.defaultCornerRadius)
                }
                .padding()
            }
        }
    }
}

struct ParagraphTextModifier<Color: hColor>: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(color)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
