import SwiftUI
import hCoreUI

extension View {
    func handleChangePayoutMethod(presented: Binding<Bool>) -> some View {
        detent(
            presented: presented,
            presentationStyle: .detent(style: [.height]),
            options: .constant(.alwaysOpenOnTop)
        ) {
            PayoutChangeMethodScreen()
                .hFormContentPosition(.compact)
                .embededInNavigation(
                    options: [.navigationBarHidden],
                    tracking: String(describing: PayoutChangeMethodScreen.self)
                )
        }
    }
}
