import SwiftUI
import hCore
import hCoreUI

struct PaymentRemoveMethodScreen: View {
    @StateObject private var vm: PaymentRemoveMethodViewModel
    @Environment(\.dismiss) private var dismiss
    private let onSuccess: () -> Void

    init(method: ConnectedPaymentMethod, onSuccess: @escaping () -> Void) {
        _vm = StateObject(wrappedValue: PaymentRemoveMethodViewModel(method: method))
        self.onSuccess = onSuccess
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding16) {
                    RemovedMethodGraphic(provider: vm.method.provider)
                        .padding(.vertical, .padding64)
                    PaymentMethodRow(vm.method, accessory: .none)
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
            title: .init(.small, .body1, L10n.paymentRemoveTitle, alignment: .center),
            subTitle: .init(.small, .body1, L10n.paymentRemoveSubtitle, alignment: .center)
        )
        .hFormContentPosition(.compact)
        .disabled(vm.isLoading)
    }

    private var confirmButton: some View {
        hButton(.large, .primary, content: .init(title: L10n.removeConfirmationButton)) {
            if await vm.remove() {
                onSuccess()
            }
        }
        .hButtonIsLoading(vm.isLoading)
    }
}

private struct RemovedMethodGraphic: View {
    let provider: PaymentProvider

    private let size: CGFloat = 74
    private let badgeSize: CGFloat = 24

    var body: some View {
        hFillColor.Opaque.white
            .frame(width: size, height: size)
            .overlay {
                provider.removalImage(size: size * 0.525)
            }
            .paymentMethodTile()
            .overlay(alignment: .topTrailing) {
                badge
                    .offset(x: badgeSize / 3, y: -badgeSize / 3)
            }
            .accessibilityHidden(true)
    }

    private var badge: some View {
        Circle()
            .fill(hFillColor.Opaque.primary)
            .frame(width: badgeSize, height: badgeSize)
            .overlay {
                hCoreUIAssets.minus.view
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: badgeSize * 0.75)
                    .foregroundColor(hTextColor.Opaque.negative)
            }
    }
}

extension PaymentProvider {
    @MainActor
    @ViewBuilder
    fileprivate func removalImage(size: CGFloat) -> some View {
        switch self {
        case .trustly:
            hCoreUIAssets.trustly.view
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size)
                .foregroundColor(hTextColor.Opaque.primary)
        case .swish:
            hCoreUIAssets.swish.view
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size)
        case .nordea:
            hCoreUIAssets.payments.view
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size)
        case .invoice:
            hCoreUIAssets.kivra.view
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size)
        case .unknown:
            EmptyView()
        }
    }
}

@MainActor
class PaymentRemoveMethodViewModel: PaymentActionViewModel {
    let method: ConnectedPaymentMethod

    init(method: ConnectedPaymentMethod) {
        self.method = method
        super.init()
    }

    func remove() async -> Bool {
        await perform { try await paymentService.removePaymentMethod(method.provider) }
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    return PaymentRemoveMethodScreen(
        method: .init(
            status: .active,
            isDefault: true,
            method: .swish(phoneNumber: "070-990 12 32")
        ),
        onSuccess: {}
    )
}
