import SwiftUI
import hCore
import hCoreUI

struct ConfirmDefaultPaymentMethodScreen: View {
    let method: ConnectedPaymentMethod
    let onSuccess: () -> Void

    var body: some View {
        PaymentMethodActionSheet(
            vm: .setDefault(method),
            title: .init(.navigationLike, .body1, L10n.paymentPrimaryConfirmTitle, alignment: .center),
            showsPrimaryLabel: true,
            confirmTitle: L10n.generalConfirm,
            hero: {
                InfoCard(text: L10n.paymentConfirmPrimaryWarning(method.provider.payinTitle), type: .info)
            },
            onSuccess: onSuccess
        )
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    return ConfirmDefaultPaymentMethodScreen(
        method: .init(
            status: .active,
            isDefault: false,
            method: .swish(phoneNumber: "070-990 12 32")
        ),
        onSuccess: {}
    )
}
