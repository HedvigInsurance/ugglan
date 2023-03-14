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

                VStack {
                    Spacer()

                    VStack(spacing: 16) {

                        Image(uiImage: hCoreUIAssets.circularCheckmark.image) /* TODO: CHANGE TO FILLED? */
                        hText("3 020 kr", style: .title1) /* TODO: CHANGE */
                            .foregroundColor(hLabelColor.primary)
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

struct SubmitClaimCheckoutTransferringDoneScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimCheckoutTransferringDoneScreen()
    }
}
