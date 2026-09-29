import Payment
import SwiftUI
import hCore
import hCoreUI

struct OnboardingConnectPaymentScreen: View {
    @EnvironmentObject var vm: OnboardingNavigationViewModel

    var body: some View {
        PaymentAddPaymentMethod(
            heading: .init(
                title: L10n.onboardingConnectPaymentTitle,
                subTitle: L10n.onboardingConnectPaymentSubtitle,
                alignment: .leading
            ),
            phoneNumber: vm.enteredPhoneNumber,
            connectedProvider: vm.connectedPaymentProvider
        ) { provider in
            // Connecting is the only way on from here, so the step is done and connected.
            vm.markPaymentConnected(provider: provider)
            vm.advance(after: .connectPayment(isConnected: true, paymentProvider: provider))
        }
        .hFormContentPosition(.center)
    }
}

#Preview("Not connected") {
    let model = OnboardingNavigationViewModel()
    model.steps = [.connectPayment(isConnected: false, paymentProvider: nil)]
    return OnboardingConnectPaymentScreen()
        .environmentObject(model)
}

#Preview("Already connected") {
    let model = OnboardingNavigationViewModel()
    model.steps = [.connectPayment(isConnected: true, paymentProvider: .swish)]
    return OnboardingConnectPaymentScreen()
        .environmentObject(model)
}
