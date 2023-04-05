import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimCheckoutTransferringDoneScreen: View {
    @PresentableStore var store: ClaimsStore
    @State var hasActionCompleted: Bool = false

    public init() {}

    public var body: some View {
        BlurredProgressOverlay {
            ZStack(alignment: .center) {
                VStack {
                    Spacer()
                        .scaleEffect(
                            x: hasActionCompleted ? 2 : 1,
                            y: hasActionCompleted ? 2 : 1,
                            anchor: .center
                        )
                    Spacer()
                }
                .opacity(hasActionCompleted ? 0 : 1)
                .animation(.spring(), value: hasActionCompleted)
                LoadingViewWithState(.claimNextSingleItemCheckout) {
                    successView()
                } onLoading: {
                    ProgressView()
                } onError: { error in
                    errorView(withError: error)
                }
                .onAppear {
                    if !hasActionCompleted {
                        Task {
                            await delay(2)
                            withAnimation {
                                hasActionCompleted = true
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func successView() -> some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Image(uiImage: hCoreUIAssets.circularCheckmark.image)
                PresentableStoreLens(
                    ClaimsStore.self,
                    getter: { state in
                        state.singleItemCheckoutStep
                    }
                ) { singleItemCheckoutStep in
                    if checkIfNotDecimal(value: singleItemCheckoutStep?.price.amount ?? 0) {

                        hText(
                            formatDoubleWithoutDecimal(value: singleItemCheckoutStep?.price.amount ?? 0.0) + " "
                                + (singleItemCheckoutStep?.price.currencyCode ?? ""),
                            style: .title1
                        )
                        .foregroundColor(hLabelColor.primary)

                    } else {
                        hText(
                            formatDoubleWithDecimal(value: singleItemCheckoutStep?.payoutAmount.amount ?? 0)
                                + " "
                                + (singleItemCheckoutStep?.payoutAmount.currencyCode ?? ""),
                            style: .title1
                        )
                        .foregroundColor(hLabelColor.primary)
                    }
                }
                hText(L10n.Claims.Payout.Success.message, style: .footnote)
                    .foregroundColor(hLabelColor.primary)

            }
            .scaleEffect(
                x: hasActionCompleted ? 1 : 0.3,
                y: hasActionCompleted ? 1 : 0.3,
                anchor: .center
            )

            Spacer()

            hButton.LargeButtonFilled {
                store.send(.dissmissNewClaimFlow)
            } content: {
                hText(L10n.generalContinueButton)
            }
        }
        .opacity(hasActionCompleted ? 1 : 0)
        .disabled(!hasActionCompleted)
        .animation(
            .interpolatingSpring(
                stiffness: 170,
                damping: 15
            )
            .delay(0.25),
            value: hasActionCompleted
        )
    }

    @ViewBuilder
    private func errorView(withError error: String) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Image(uiImage: hCoreUIAssets.circularCross.image)
                hText(L10n.somethingWentWrong, style: .title1)
                    .foregroundColor(hLabelColor.primary)
                hText(error, style: .footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(hLabelColor.primary)
            }
            .scaleEffect(
                x: hasActionCompleted ? 1 : 0.3,
                y: hasActionCompleted ? 1 : 0.3,
                anchor: .center
            )

            Spacer()

            hButton.LargeButtonFilled {
                store.send(.setLoadingState(action: .claimNextSingleItemCheckout, state: .loading))
                Task {
                    await delay(2)
                    store.send(.setLoadingState(action: .claimNextSingleItemCheckout, state: nil))
                }
            } content: {
                hText(L10n.generalRetry)
            }

            HStack {
                hButton.LargeButtonFilled {
                    store.send(.dissmissNewClaimFlow)
                } content: {
                    hText(L10n.generalCloseButton)
                }

                hButton.LargeButtonFilled {
                    store.send(.dissmissNewClaimFlow)
                    store.send(.openFreeTextChat)
                } content: {
                    hText(L10n.openChat)
                }
            }

        }
        .opacity(hasActionCompleted ? 1 : 0)
        .disabled(!hasActionCompleted)
        .animation(
            .interpolatingSpring(
                stiffness: 170,
                damping: 15
            )
            .delay(0.25),
            value: hasActionCompleted
        )

    }

    func checkIfNotDecimal(value: Double) -> Bool {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return true
        }
        return false
    }

    func formatDoubleWithoutDecimal(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter.string(for: value) ?? ""
    }

    func formatDoubleWithDecimal(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        return formatter.string(for: value) ?? ""
    }
}

struct SubmitClaimCheckoutTransferringDoneScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimCheckoutTransferringDoneScreen()
    }
}
