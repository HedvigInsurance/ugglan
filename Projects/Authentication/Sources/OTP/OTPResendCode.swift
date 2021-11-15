import Foundation
import SwiftUI
import hCoreUI

struct ResendOTPCode: View {
    @State var canResendAtText: String = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    func updateText(timeUntil: Int) {
        canResendAtText = "Resend code in \(String(timeUntil))s"
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
                hButton.SmallButtonFilled {

                } content: {
                    hText("Resend")
                }
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
