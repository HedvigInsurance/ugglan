import SwiftUI
import hCore
import hCoreUI

struct PayoutChangeMethodScreen: View {
    @ObservedObject var vm: PaymentStatusViewModel
    var body: some View {
        hForm {
            VStack(spacing: .padding4) {
                ForEach(vm.paymentStatusData.availableMethods.filter { $0.supportsPayout }, id: \.provider) { method in
                    hSection {
                        hRow {
                            VStack(alignment: .leading, spacing: .padding4) {
                                hText(method.provider.payoutTitle)
                                hText(method.provider.payoutSubtitle, style: .label)
                                    .foregroundColor(hTextColor.Translucent.secondary)
                            }
                            Spacer()
                        }
                        .withChevronAccessory
                    }
                }
            }
        }
    }
}

extension PaymentProvider {
    var payoutTitle: String {
        switch self {
        case .nordea: return L10n.bankPayoutMethodCardTitle
        case .swish: return ""
        case .trustly: return ""
        case .invoice: return L10n.paymentsInvoice
        case .unknown: return ""
        }
    }

    var payoutSubtitle: String {
        switch self {
        case .nordea: return L10n.bankPayoutMethodCardDescription
        case .swish: return ""
        case .trustly: return ""
        case .invoice: return ""
        case .unknown: return ""
        }
    }
}

#Preview {
    PayoutChangeMethodScreen(
        vm: .init(
            paymentStatusData: .init(
                status: .active,
                chargingDay: nil,
                defaultPayinMethod: nil,
                payinMethods: [],
                defaultPayoutMethod: nil,
                payoutMethods: [],
                availableMethods: [
                    .init(provider: .nordea, supportsPayin: false, supportsPayout: true),
                    .init(provider: .swish, supportsPayin: false, supportsPayout: true),
                    .init(provider: .trustly, supportsPayin: true, supportsPayout: true),
                ]
            )
        )
    )
}
