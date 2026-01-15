import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatHonestyPledgeScreen: View {
    @EnvironmentObject var router: Router
    @State private var hasAgreedToHonestyPledge = false
    let onConfirm: () -> Void
    var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                ImportantInformationView(
                    title: L10n.honestyPledgeTitle,
                    subtitle: L10n.honestyPledgeDescription,
                    confirmationMessage: L10n.claimsPledgeSlideLabel,
                    isConfirmed: $hasAgreedToHonestyPledge
                )
                hSection {
                    VStack(spacing: .padding8) {
                        hContinueButton {
                            onConfirm()
                        }
                        .disabled(!hasAgreedToHonestyPledge)
                        hButton(
                            .large,
                            .secondary,
                            content: .init(title: L10n.generalCancelButton)
                        ) {
                            router.dismiss()
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
            }
            .padding(.top, .padding32)
        }
        .hFormContentPosition(.compact)
    }
}

#Preview {
    VStack {
        Spacer()
        SubmitClaimChatHonestyPledgeScreen {}
    }
}
