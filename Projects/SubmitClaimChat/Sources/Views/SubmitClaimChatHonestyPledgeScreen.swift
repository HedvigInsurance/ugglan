import Environment
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatHonestyPledgeScreen: View {
    @EnvironmentObject var router: Router
    @State private var hasAgreedToHonestyPledge = false
    let onConfirm: () -> Void
    let onConfirmOldFlow: () -> Void
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
                        continueButton
                        if Environment.current == .staging {
                            oldFlowButton
                        }
                        cancelButton
                    }
                }
                .sectionContainerStyle(.transparent)
            }
            .padding(.top, .padding32)
        }
        .hFormContentPosition(.compact)
    }

    private var continueButton: some View {
        hContinueButton {
            onConfirm()
        }
        .disabled(!hasAgreedToHonestyPledge)
    }

    @ViewBuilder
    private var oldFlowButton: some View {
        hButton(.large, .secondary, content: .init(title: "Start old flow")) {
            onConfirmOldFlow()
        }
        .disabled(!hasAgreedToHonestyPledge)
    }

    private var cancelButton: some View {
        hButton(.large, .secondary, content: .init(title: L10n.generalCancelButton)) {
            router.dismiss()
        }
    }
}

#Preview {
    VStack {
        Spacer()
        SubmitClaimChatHonestyPledgeScreen {
        } onConfirmOldFlow: {
        }
    }
}
