import SwiftUI
import hCore
import hCoreUI

struct PaymentRemoveMethodScreen: View {
    let method: ConnectedPaymentMethod
    let onSuccess: () -> Void

    var body: some View {
        PaymentMethodActionSheet(
            vm: .remove(method),
            title: .init(.small, .body1, L10n.paymentRemoveTitle, alignment: .center),
            subTitle: .init(.small, .body1, L10n.paymentRemoveSubtitle, alignment: .center),
            confirmTitle: L10n.removeConfirmationButton,
            hero: {
                RemovedMethodGraphic(provider: method.provider)
                    .padding(.vertical, .padding64)
            },
            onSuccess: onSuccess
        )
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
