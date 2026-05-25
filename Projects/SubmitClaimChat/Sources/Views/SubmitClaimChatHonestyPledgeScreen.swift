import Environment
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatHonestyPledgeScreen: View {
    @EnvironmentObject var router: NavigationRouter
    @State private var hasAgreedToHonestyPledge = false
    let hasOngoingClaim: Bool
    let onConfirm: (_ inProgress: Bool, _ withAnimations: Bool) -> Void

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
                        if hasOngoingClaim {
                            hButton(.large, .primary, content: .init(title: "Start a new claim")) {
                                onConfirm(false, true)
                            }
                            .disabled(!hasAgreedToHonestyPledge)
                        } else {
                            continueButtonWithAnimations()
                                .disabled(!hasAgreedToHonestyPledge)
                        }
                        //                        if Environment.current == .staging {
                        //                            continueButtonWithAnimations(false)
                        //                        }
                        if hasOngoingClaim {
                            hButton(.large, .primaryAlt, content: .init(title: "Continue where you stopped")) {
                                onConfirm(true, true)
                            }
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
                    onConfirm(false, enabled)
                }
            } else {
                hButton(.large, .secondary, content: .init(title: "Without animations")) {
                    onConfirm(false, enabled)
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
        SubmitClaimChatHonestyPledgeScreen(hasOngoingClaim: false, onConfirm: { _, _ in })
    }
}
