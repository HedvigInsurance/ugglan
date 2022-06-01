import SwiftUI
import hCoreUI

struct DeleteAccountView: View {
    @ObservedObject var viewModel: DeleteAccountViewModel
    
    var body: some View {
//        if viewModel.hasActiveClaims {
//            // TODO: The signal for claims has issues as claim.claimDetailData.status is always returned as .none
//            BlockAccountDeletionView()
//        } else if viewModel.hasActiveContracts {
//            // TODO: Check if the signal for hasActiveContracts is working properly
//            BlockAccountDeletionView()
//        } else {
            // Show the screen for deleting claims
            hForm {
                hText("Are you sure you want to delete your account?", style: .title2)
                    .foregroundColor(hLabelColor.primary)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                hSection {
                    hText("Information you have contributed to Hedvig will be kept due to regulations, but it will not be linked to you:", style: .callout)
                        .modifier(ParagraphTextModifier(color: hLabelColor.secondary, padding: 16))
                }
                
                hSection {
                    hText(
                        "After sending a request we will contact you in 1–2 business days for further steps.",
                        style: .callout
                    )
                    .modifier(ParagraphTextModifier(color: hLabelColor.secondary, padding: 16))
                }
            }
            .hFormAttachToBottom {
                VStack {
                    Button {
                        viewModel.deleteMemberRequest()
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
            .onAppear {
                viewModel.fetchMemberDetails()
            }
//        }
    }
}

struct ParagraphTextModifier<Color: hColor>: ViewModifier {
    var color: Color
    var padding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .padding(padding)
            .foregroundColor(color)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
