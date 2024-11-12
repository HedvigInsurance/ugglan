import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimCheckoutTransferringScreen: View {
    @EnvironmentObject var claimsNavigationVm: ClaimsNavigationViewModel
    @State var loadingAnimation: Bool = false
    @State var successAnimation: Bool = false
    @State var errorAnimation: Bool = false
    @State var progress: Float = 0

    @Namespace private var animation
    init() {}

    var body: some View {
        BlurredProgressOverlay {
            ZStack(alignment: .center) {
                VStack {
                    Spacer()
                        .scaleEffect(
                            x: loadingAnimation ? 2 : 1,
                            y: loadingAnimation ? 2 : 1,
                            anchor: .center
                        )
                    Spacer()
                }
                .opacity(loadingAnimation ? 0 : 1)
                .animation(.spring(), value: loadingAnimation)

                ProcessingStateView(
                    loadingViewText: L10n.claimsPayoutProgresLabel,
                    state: $claimsNavigationVm.submitClaimCheckoutVm.viewState,
                    duration: 6
                )
                .hCustomSuccessView {
                    successView()
                }
                .hErrorViewButtonConfig(
                    errorButtons
                )
                .transition(
                    .scale.animation(
                        .interpolatingSpring(
                            stiffness: 170,
                            damping: 15
                        )
                    )
                )
            }
            .padding(.horizontal, .padding24)
        }
    }

    private var errorButtons: ErrorViewButtonConfig {
        .init(
            actionButton: .init(
                buttonTitle: L10n.generalRetry,
                buttonAction: {
                    Task {
                        let step = await claimsNavigationVm.submitClaimCheckoutVm.singleItemRequest(
                            context: claimsNavigationVm.currentClaimContext ?? "",
                            model: claimsNavigationVm.singleItemCheckoutModel
                        )

                        if let step {
                            claimsNavigationVm.navigate(data: step)
                        }
                    }
                }
            ),
            dismissButton: .init(
                buttonTitle: L10n.generalCloseButton,
                buttonAction: {
                    claimsNavigationVm.router.dismiss()
                }
            )
        )
    }

    @ViewBuilder
    private func successView() -> some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                let singleItemCheckoutStep = claimsNavigationVm.singleItemCheckoutModel

                hText(
                    (singleItemCheckoutStep?.compensation.payoutAmount.formattedAmount ?? ""),
                    style: .displayXSLong
                )
                .foregroundColor(hTextColor.Opaque.primary)
                hSection {
                    hText(L10n.claimsPayoutSuccessLabel, style: .body1)
                        .foregroundColor(hTextColor.Opaque.secondary)
                        .multilineTextAlignment(.center)
                }
                .sectionContainerStyle(.transparent)
            }
            .onAppear {
                ImpactGenerator.soft()
            }
            .scaleEffect(
                x: successAnimation ? 1 : 0.3,
                y: successAnimation ? 1 : 0.3,
                anchor: .center
            )
            Spacer()
            hButton.LargeButton(type: .ghost) {
                claimsNavigationVm.router.dismiss()
            } content: {
                hText(L10n.generalCloseButton, style: .body1)
                    .foregroundColor(hTextColor.Opaque.primary)
            }
        }
        .opacity(successAnimation ? 1 : 0)
        .disabled(!successAnimation)
        .animation(
            .interpolatingSpring(
                stiffness: 170,
                damping: 15
            )
            .delay(0.25),
            value: successAnimation
        )
        .onAppear {
            if !successAnimation {
                withAnimation {
                    successAnimation = true
                }
            }
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> SubmitClaimClient in SubmitClaimClientDemo() })
    Dependencies.shared.add(module: Module { () -> hFetchEntrypointsClient in FetchEntrypointsClientDemo() })
    return SubmitClaimCheckoutTransferringScreen()
        .environmentObject(ClaimsNavigationViewModel())
}
