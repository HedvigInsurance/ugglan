import PresentableStore
import SwiftUI
import hCoreUI

struct PayoutChangeMethodScreen: View {
    @ObservedObject var vm: PaymentStatusViewModel
    @EnvironmentObject var paymentNavigationVm: PaymentsNavigationViewModel
    @EnvironmentObject var router: NavigationRouter
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
                        .onTap {
                            switch method.provider {
                            case .trustly:
                                paymentNavigationVm.connectPaymentVm.set(
                                    forPayin: false,
                                    forPayout: true,
                                    onSuccess: { [weak router] in
                                        router?.pop()
                                    }
                                )
                            case .invoice: break
                            case .nordea: break
                            case .swish: break
                            case .unknown: break
                            }
                        }
                    }
                }
            }
        }
    }
}

extension PaymentProvider {
    var payoutTitle: String {
        switch self {
        case .nordea: return "Bankkonto"
        case .swish: return "Swish"
        case .trustly: return "Trustly"
        case .invoice: return "Faktura"
        case .unknown: return ""
        }
    }

    var payoutSubtitle: String {
        switch self {
        case .nordea: return "Utbetalning till ett svensk bankkonto"
        case .swish: return "Snabb utbetalning med Swish"
        case .trustly: return "Direktutbetalning via Trustly"
        case .invoice: return "Faktura till kivra/email"
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
                payinMethods: [],
                payoutMethods: [],
                availableMethods: [
                    .init(provider: .nordea, supportsPayin: false, supportsPayout: true),
                    .init(provider: .swish, supportsPayin: false, supportsPayout: true),
                    .init(provider: .trustly, supportsPayin: true, supportsPayout: true),
                ]
            )
        )
    )
    .environmentObject(NavigationRouter())
    .environmentObject(PaymentsNavigationViewModel())
}
