import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

struct PaymentsChooseDefaultScreen: View {
    @AppObservedObject var store: PaymentStore
    @Environment(\.dismiss) private var dismiss

    @State private var currentDefault: ConnectedPaymentMethod?
    @State private var methodToConfirm: ConnectedPaymentMethod?

    var body: some View {
        hForm {
            PaymentMethodPickerGraphic(selected: currentDefault?.provider)
                .padding(.vertical, .padding64)
        }
        .hFormAttachToBottom {
            if let data = store.paymentStatusData?.selectablePayinMethods {
                hSection {
                    hRadioOptionList(data, spacing: .padding8) { element in
                        PaymentMethodRow(element, selection: $currentDefault)
                    }
                }
                .sectionContainerStyle(.transparent)
            }
            hSection {
                VStack(spacing: .padding8) {
                    hButton(.large, .primary, content: .init(title: L10n.generalConfirm)) {
                        methodToConfirm = currentDefault
                    }
                    .disabled(currentDefault == nil)
                    hButton(.large, .ghost, content: .init(title: L10n.generalCancelButton)) {
                        dismiss()
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormTitle(
            title: .init(.small, .body1, L10n.paymentPrimaryTitle, alignment: .center),
            subTitle: .init(.small, .body1, L10n.paymentPrimarySubtitle, alignment: .center)
        )
        .hFormContentPosition(.compact)
        .detent(
            item: $methodToConfirm,
            presentationStyle: .detent(style: [.height])
        ) { method in
            PaymentsConfirmDefaultScreen(method: method) {
                methodToConfirm = nil
                dismiss()
                PaymentStore.refreshStatusDetached()
            }
        }
    }
}

#Preview {
    let store: PaymentStore = globalAppStateContainer.get()
    store.paymentStatusData = .init(
        status: .active,
        chargingDay: 27,
        defaultPayinMethod: .init(
            status: .active,
            isDefault: true,
            method: .trustly(bankAccount: .init(account: "account", bank: "bank"))
        ),
        payinMethods: [
            .init(
                status: .active,
                isDefault: true,
                method: .trustly(bankAccount: .init(account: "account", bank: "bank"))
            ),
            .init(
                status: .active,
                isDefault: false,
                method: .swish(phoneNumber: "0701231231")
            ),
            .init(
                status: .pending,
                isDefault: false,
                method: .invoice(delivery: .kivra)
            ),
        ],
        defaultPayoutMethod: nil,
        payoutMethods: [],
        availableMethods: [],
        missingConnection: nil,
        layout: .other
    )
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    return PaymentsChooseDefaultScreen()
}
