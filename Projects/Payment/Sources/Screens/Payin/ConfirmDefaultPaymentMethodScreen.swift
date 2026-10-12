import SwiftUI
import hCore
import hCoreUI

struct ConfirmDefaultPaymentMethodScreen: View {
    let method: ConnectedPaymentMethod
    var direction: PaymentDirection = .payin
    let onSuccess: () -> Void

    var body: some View {
        PaymentMethodActionSheet(
            vm: direction == .payin ? .setDefault(method) : .setDefaultPayout(method),
            title: .init(.navigationLike, .body1, confirmTitle, alignment: .center),
            showsPrimaryLabel: true,
            confirmTitle: L10n.generalConfirm,
            hero: {
                InfoCard(text: warning, type: .info)
            },
            onSuccess: onSuccess
        )
    }

    private var confirmTitle: String {
        switch direction {
        case .payin: L10n.paymentPrimaryConfirmTitle
        case .payout: L10n.payoutConfirmationTitle
        }
    }

    private var warning: String {
        switch direction {
        case .payin: L10n.paymentConfirmPrimaryWarning(method.provider.payinTitle)
        case .payout: L10n.payoutConfirmationInfo(method.provider.payoutTitle)
        }
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
