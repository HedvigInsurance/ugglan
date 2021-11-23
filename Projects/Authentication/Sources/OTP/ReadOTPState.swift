import Foundation
import SwiftUI
import hCore

struct ReadOTPState<Content: View>: View {
    var content: (_ state: OTPState) -> Content

    init(
        @ViewBuilder _ content: @escaping (_ state: OTPState) -> Content
    ) {
        self.content = content
    }

    var body: some View {
        PresentableStoreLens(
            AuthenticationStore.self,
            getter: { state in
                state.otpState
            }
        ) { state in
            content(state)
        }
    }
}
