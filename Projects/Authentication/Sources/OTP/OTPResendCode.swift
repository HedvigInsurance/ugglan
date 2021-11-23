import Foundation
import SwiftUI
import hCore
import hCoreUI

struct ResendOTPCode: View {
    @PresentableStore var store: AuthenticationStore
    @State var canResendAtText: String = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    func updateText(timeUntil: Int) {
        canResendAtText = L10n.Login.MediumButton.Inactive.resendCodeIn(timeUntil)
    }

    func timeUntil(state: OTPState) -> Int {
        guard let date = state.canResendAt else {
            return 0
        }

        return Int(Date().timeIntervalSince(date))
    }

    var body: some View {
        ReadOTPState { state in
            if timeUntil(state: state) >= 0 {
                SwiftUI.Button {
                    store.send(.otpStateAction(action: .resendCode))
                } label: {
                    HStack(spacing: 8) {
                        Image(uiImage: hCoreUIAssets.refresh.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .rotationEffect(state.isResending ? Angle(degrees: 0) : Angle(degrees: -360))
                            .animation(
                                state.isResending ? .linear(duration: 1).repeatForever(autoreverses: false) : .default
                            )
                        hText(L10n.Login.SmediumButton.Active.resendCode, style: .subheadline)
                    }
                }
                .tint(hLabelColor.primary)
            } else {
                hText(
                    canResendAtText,
                    style: .subheadline
                )
                .foregroundColor(hLabelColor.tertiary)
                .onReceive(timer) { _ in
                    updateText(timeUntil: abs(timeUntil(state: state)))
                }
                .onAppear {
                    updateText(timeUntil: abs(timeUntil(state: state)))
                }
            }
        }
        .padding(.top, 44)
    }
}
