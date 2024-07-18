import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimCheckoutTransferringScreen: View {
    @PresentableStore var store: SubmitClaimStore
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
                LoadingViewWithState(SubmitClaimStore.self, .postSingleItemCheckout) {
                    successView()
                } onLoading: {
                    loadingView()
                } onError: { error in
                    errorView(withError: error)
                }
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

    @ViewBuilder
    private func successView() -> some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                PresentableStoreLens(
                    SubmitClaimStore.self,
                    getter: { state in
                        state.singleItemCheckoutStep
                    }
                ) { singleItemCheckoutStep in

                    hText(
                        (singleItemCheckoutStep?.compensation.payoutAmount.formattedAmount ?? ""),
                        style: .title1
                    )
                    .foregroundColor(hTextColor.Opaque.primary)
                }
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
                store.send(.dismissNewClaimFlow)
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

    @ViewBuilder
    private func loadingView() -> some View {
        VStack {
            Spacer()
            VStack(spacing: 24) {
                hText(L10n.claimsPayoutProgresLabel)
                ProgressView(value: progress)
                    .frame(width: UIScreen.main.bounds.width * 0.53)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeInOut(duration: 1.5).delay(0.5)) {
                                progress = 1
                            }
                        }
                    }
                    .progressViewStyle(hProgressViewStyle())
            }
            .frame(maxHeight: .infinity)
            .scaleEffect(
                x: loadingAnimation ? 1 : 0.3,
                y: loadingAnimation ? 1 : 0.3,
                anchor: .top
            )

            Spacer()
        }
        .padding(.bottom, .padding40)
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
                Image(uiImage: hCoreUIAssets.warningTriangleOutlined.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                hText(L10n.HomeTab.errorTitle, style: .title3)
                    .foregroundColor(hTextColor.Opaque.primary)
                hText(error, style: .body1)
                    .multilineTextAlignment(.center)
                    .foregroundColor(hTextColor.Opaque.primary)
            }
            .scaleEffect(
                x: errorAnimation ? 1 : 0.3,
                y: errorAnimation ? 1 : 0.3,
                anchor: .center
            )

            Spacer()

            hSection {
                hButton.LargeButton(type: .primary) {
                    store.send(.dismissNewClaimFlow)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        store.send(.submitClaimOpenFreeTextChat)
                    }
                } content: {
                    hText(L10n.openChat, style: .body1)
                }
                .cornerRadius(.cornerRadiusL)
            }
            .sectionContainerStyle(.transparent)
            HStack {
                Button {
                    store.send(.dismissNewClaimFlow)
                } label: {
                    HStack {
                        hText(L10n.generalCloseButton, style: .body1)
                            .foregroundColor(hTextColor.Opaque.secondary)
                            .padding(.padding16)
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(.cornerRadiusL)
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: .cornerRadiusL
                        )
                        .stroke(hTextColor.Opaque.primary, lineWidth: 1)
                    )
                }

                Button {
                    store.send(.singleItemCheckoutRequest)
                } label: {
                    HStack {
                        hText(L10n.generalRetry, style: .body1)
                            .foregroundColor(hTextColor.Opaque.primary)
                            .padding(.padding16)
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(.cornerRadiusL)
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: .cornerRadiusL
                        )
                        .stroke(hTextColor.Opaque.primary, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, .padding16)

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
