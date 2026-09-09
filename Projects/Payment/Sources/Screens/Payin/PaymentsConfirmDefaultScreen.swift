import SwiftUI
import hCore
import hCoreUI

struct PaymentsConfirmDefaultScreen: View {
    @StateObject private var vm: PaymentsConfirmDefaultViewModel
    @Environment(\.dismiss) private var dismiss
    private let onSuccess: () -> Void

    init(method: ConnectedPaymentMethod, onSuccess: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: PaymentsConfirmDefaultViewModel(method: method))
        self.onSuccess = onSuccess
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding16) {
                    InfoCard(text: L10n.paymentConfirmPrimaryWarning(vm.method.provider.payinTitle), type: .info)
                    PaymentMethodRow(vm.method, accessory: .none, showsPrimaryLabel: true)
                    VStack(spacing: .padding8) {
                        if let errorMessage = vm.errorMessage {
                            PaymentErrorLabel(message: errorMessage)
                        }
                        confirmButton
                        hButton(.large, .ghost, content: .init(title: L10n.generalCancelButton)) {
                            dismiss()
                        }
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .hFormTitle(
            title: .init(.navigationLike, .body1, L10n.paymentPrimaryConfirmTitle, alignment: .center)
        )
        .hFormContentPosition(.compact)
        .disabled(vm.isLoading)
    }

    private var confirmButton: some View {
        hButton(.large, .primary, content: .init(title: L10n.generalConfirm)) {
            if await vm.confirm() {
                onSuccess()
            }
        }
        .hButtonIsLoading(vm.isLoading)
    }
}

@MainActor
class PaymentsConfirmDefaultViewModel: PaymentActionViewModel {
    let method: ConnectedPaymentMethod

    init(method: ConnectedPaymentMethod) {
        self.method = method
        super.init()
    }

    func confirm() async -> Bool {
        await perform { try await paymentService.setDefaultPaymentMethod(method.method) }
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    return PaymentsConfirmDefaultScreen(
        method: .init(
            status: .active,
            isDefault: false,
            method: .swish(phoneNumber: "070-990 12 32")
        ),
        onSuccess: {}
    )
}
