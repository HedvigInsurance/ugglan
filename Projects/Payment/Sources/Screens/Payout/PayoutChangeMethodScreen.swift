import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct PayoutChangeMethodScreen: View {
    @ObservedObject var vm: PaymentStatusViewModel
    @EnvironmentObject var paymentNavigationVm: PaymentsNavigationViewModel
    @EnvironmentObject var router: NavigationRouter
    var body: some View {
        hForm {
            VStack(spacing: .padding4) {
                ForEach(vm.paymentStatusData.availablePayoutMethods, id: \.provider) { method in
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
                            case .nordea: paymentNavigationVm.showNordeaSetup = true
                            case .swish: paymentNavigationVm.showSwishPayoutSetup = true
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
        case .nordea: return L10n.bankPayoutMethodCardTitle
        case .swish: return "Swish"
        case .trustly: return "Trustly"
        case .invoice: return L10n.paymentsInvoice
        case .unknown: return ""
        }
    }

    var payoutSubtitle: String {
        switch self {
        case .nordea: return L10n.bankPayoutMethodCardDescription
        case .swish: return L10n.bankPayoutMethodSwishDescription
        case .trustly: return L10n.bankPayoutMethodTrustlyDescription
        case .invoice: return L10n.bankPayoutMethodInvoiceDescription
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
    .environmentObject(NavigationRouter())
    .environmentObject(PaymentsNavigationViewModel())
}
