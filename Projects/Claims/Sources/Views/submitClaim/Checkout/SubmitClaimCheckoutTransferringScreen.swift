import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimCheckoutTransferringScreen: View {
    @PresentableStore var store: ClaimsStore
    @State var loadingAnimation: Bool = false
    @State var successAnimation: Bool = false
    @State var errorAnimation: Bool = false

    @Namespace private var animation
    public init() {}

    public var body: some View {
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
                LoadingViewWithState(.postSingleItemCheckout) {
                    successView()
                } onLoading: {
                    loadingView()
                } onError: { error in
                    errorView(withError: error)
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
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                PresentableStoreLens(
                    ClaimsStore.self,
                    getter: { state in
                        state.singleItemCheckoutStep
                    }
                ) { singleItemCheckoutStep in

                    hText(
                        (singleItemCheckoutStep?.payoutAmount.formattedAmount ?? ""),
                        style: .title1
                    )
                    .foregroundColor(hLabelColor.primary)
                }
                hText(L10n.Claims.Payout.Success.message, style: .footnote)
                    .foregroundColor(hLabelColor.primary)
                    .matchedGeometryEffect(id: "titleLabel", in: animation)
            }
            .scaleEffect(
                x: successAnimation ? 1 : 0.3,
                y: successAnimation ? 1 : 0.3,
                anchor: .center
            )
            Spacer()
            hButton.LargeButtonFilled {
                store.send(.dissmissNewClaimFlow)
            } content: {
                hText(L10n.generalContinueButton)
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

    @ViewBuilder
    private func loadingView() -> some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {
                hText(L10n.Claims.Payout.Progress.title, style: .title2)
                    .matchedGeometryEffect(id: "titleLabel", in: animation)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .scaleEffect(
                x: loadingAnimation ? 1 : 0.3,
                y: loadingAnimation ? 1 : 0.3,
                anchor: .top
            )

            Spacer()
        }
        .opacity(loadingAnimation ? 1 : 0)
        .disabled(!loadingAnimation)
        .animation(
            .interpolatingSpring(
                stiffness: 170,
                damping: 15
            )
            .delay(0.25),
            value: loadingAnimation
        )
        .onAppear {
            if !loadingAnimation {
                withAnimation {
                    loadingAnimation = true
                }
            }
        }
    }

    @ViewBuilder
    private func errorView(withError error: String) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Image(uiImage: hCoreUIAssets.warningTriangle.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                hText(L10n.HomeTab.errorTitle, style: .title1)
                    .foregroundColor(hLabelColor.primary)
                hText(error, style: .footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(hLabelColor.primary)
                    .matchedGeometryEffect(id: "titleLabel", in: animation)
            }
            .scaleEffect(
                x: errorAnimation ? 1 : 0.3,
                y: errorAnimation ? 1 : 0.3,
                anchor: .center
            )

            Spacer()

            hButton.LargeButtonFilled {
                store.send(.dissmissNewClaimFlow)
                store.send(.openFreeTextChat)
            } content: {
                hText(L10n.openChat)
            }
            .padding([.leading, .trailing], 16)
            .cornerRadius(.defaultCornerRadius)
            HStack {

                Button {
                    store.send(.dissmissNewClaimFlow)
                } label: {
                    HStack {
                        hText(L10n.generalCloseButton)
                            .foregroundColor(hLabelColor.primary)
                            .padding(16)
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(.defaultCornerRadius)
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: .defaultCornerRadius
                        )
                        .stroke(hLabelColor.primary, lineWidth: 1)
                    )
                }

                Button {
                    store.send(.claimNextSingleItemCheckout)
                } label: {
                    HStack {
                        hText(L10n.generalRetry)
                            .foregroundColor(hLabelColor.primary)
                            .padding(16)
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(.defaultCornerRadius)
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: .defaultCornerRadius
                        )
                        .stroke(hLabelColor.primary, lineWidth: 1)
                    )
                }
            }
            .padding([.leading, .trailing], 16)

        }
        .opacity(errorAnimation ? 1 : 0)
        .disabled(!errorAnimation)
        .animation(
            .interpolatingSpring(
                stiffness: 170,
                damping: 15
            )
            .delay(0.25),
            value: errorAnimation
        )
        .onAppear {
            if !errorAnimation {
                withAnimation {
                    errorAnimation = true
                }
            }
        }
    }
}

struct SubmitClaimCheckoutTransferringScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimCheckoutTransferringScreen()
    }
}
