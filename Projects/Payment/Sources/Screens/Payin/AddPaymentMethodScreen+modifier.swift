import SwiftUI
import hCoreUI

extension View {
    public func handleAddPaymentMethod(presented: Binding<Bool>) -> some View {
        detent(
            presented: presented,
            presentationStyle: .detent(style: [.height]),
            options: .constant(.alwaysOpenOnTop)
        ) {
            PaymentAddPaymentMethod()
                .hFormContentPosition(.compact)
        }
    }
}
