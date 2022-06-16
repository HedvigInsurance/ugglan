import SwiftUI
import hCoreUI

struct DeleteAccountView: View {
    @ObservedObject var viewModel: DeleteAccountViewModel

    private func generateBulletPoints(texts: [String]) -> String {
        texts.map { " •  \($0)" }.joined(separator: "\n")
    }

    var body: some View {
        if viewModel.hasActiveClaims || viewModel.hasActiveContracts {
            BlockAccountDeletionView()
        } else {
            hForm {
                hText("Are you sure you want to delete your account?", style: .title2)
                    .foregroundColor(hLabelColor.primary)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)

                hText("If you delete your account the following data will be gone:", style: .callout)
                    .modifier(ParagraphTextModifier(color: hLabelColor.secondary))
                    .padding(.horizontal, 16)

                hSection {
                    hText(
                        generateBulletPoints(texts: [
                            "Insurances subscription", "Insurance history", "E-mail", "Phone number", "Name",
                        ]),
                        style: .subheadline
                    )
                    .modifier(ParagraphTextModifier(color: hLabelColor.primary))
                    .padding(16)
                }

                hText(
                    "Information you have contributed to Hedvig will be kept due to regulations, but it will not be linked to you:",
                    style: .callout
                )
                .modifier(ParagraphTextModifier(color: hLabelColor.secondary))
                .padding(.horizontal, 16)

                hSection {
                    hText(
                        generateBulletPoints(texts: [
                            "All data associated with claims", "All data associated with insurance",
                        ]),
                        style: .subheadline
                    )
                    .modifier(ParagraphTextModifier(color: hLabelColor.primary))
                    .padding(16)
                }

                hText(
                    "After sending a request we will contact you in 1–2 business days for further steps.",
                    style: .callout
                )
                .modifier(ParagraphTextModifier(color: hLabelColor.secondary))
                .padding(.horizontal, 16)
            }
            .hFormAttachToBottom {
                VStack {
                    Button {
                        viewModel.deleteAccount()
                    } label: {
                        hText("I am sure I want to proceed", style: .body)
                            .foregroundColor(.white)
                    }
                    .frame(minHeight: 52)
                    .frame(minWidth: 200)
                    .frame(maxWidth: .infinity)
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
