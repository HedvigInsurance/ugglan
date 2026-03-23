import Environment
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatHonestyPledgeScreen: View {
    @EnvironmentObject var router: Router
    @State private var hasAgreedToHonestyPledge = false
    let onConfirm: (_ withAnimations: Bool) -> Void

    private let pledgeNotes = [
        L10n.honestyPledgeNote1,
        L10n.honestyPledgeNote2,
        L10n.honestyPledgeNote3,
    ]

    var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                questionView
                hSection {
                    ImportantInformationView(
                        title: L10n.honestyPledgeTitle,
                        subtitle: L10n.honestyPledgeDescription,
                        confirmationMessage: L10n.claimsPledgeSlideLabel,
                        isConfirmed: $hasAgreedToHonestyPledge
                    )
                }
                .sectionContainerStyle(.transparent)
                hSection {
                    VStack(spacing: .padding8) {
                        continueButtonWithAnimations()
                        if Environment.current == .staging {
                            continueButtonWithAnimations(false)
                        }
                        cancelButton
                    }
                }
                .sectionContainerStyle(.transparent)
            }
        }
        .hFormContentPosition(.compact)
        .hFormIgnoreBottomPadding
    }

    @ViewBuilder
    private var questionView: some View {
        hSection(pledgeNotes) { text in
            questionRowView(text: text)
        }
        .hWithoutHorizontalPadding([.row, .divider])
        .sectionContainerStyle(.transparent)
    }

    private func questionRowView(text: String) -> some View {
        hRow {
            HStack(alignment: .top, spacing: .padding8) {
                hCoreUIAssets.checkmark.view
                    .accessibilityHidden(true)
                hText(text)
                    .foregroundColor(hTextColor.Translucent.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private func continueButtonWithAnimations(_ enabled: Bool = true) -> some View {
        Group {
            if enabled {
                hContinueButton {
                    onConfirm(enabled)
                }
            } else {
                hButton(.large, .secondary, content: .init(title: "Without animations")) {
                    onConfirm(enabled)
                }
            }
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
        SubmitClaimChatHonestyPledgeScreen(onConfirm: { _ in })
    }
}
