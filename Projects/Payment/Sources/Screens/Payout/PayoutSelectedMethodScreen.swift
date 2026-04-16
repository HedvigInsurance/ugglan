import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct PayoutSelectedMethodScreen: View {
    @ObservedObject var vm: PaymentStatusViewModel
    @EnvironmentObject var router: NavigationRouter
    var body: some View {
        hForm {
            VStack(spacing: .padding8) {
                hSection {
                    hFloatingField(
                        value: vm.paymentStatusData.payoutAccountDisplayValue,
                        placeholder: vm.paymentStatusData.payoutAccountDisplayTitle,
                        error: nil,
                        onTap: {}
                    )
                    .hFieldTrailingView {
                        hCoreUIAssets.lock.view
                            .foregroundColor(hTextColor.Translucent.secondary)
                    }
                    .hBackgroundOption(option: [.locked])
                    .disabled(true)
                }
                if vm.paymentStatusData.payoutMethods.hasMethodInProgress {
                    hSection {
                        InfoCard(text: L10n.myPaymentUpdatingMessage, type: .info)
                    }
                    .sectionContainerStyle(.transparent)
                }

                if vm.paymentStatusData.showChangeButton {
                    hSection {
                        hButton(
                            .large,
                            .primary,
                            content: .init(title: L10n.changePayoutMethodButtonLabel),
                            {
                                router.push(
                                    PayoutRouterAction.setupPayoutMethod
                                )
                            }
                        )
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
        }
    }
}

extension PaymentStatusData {
    fileprivate var payoutAccountDisplayValue: String {
        guard let method = defaultPayoutMethod else { return "" }
        switch method.details {
        case .bankAccount(let account, let bank):
            return "\(bank) \(account)"
        case .swish(let phoneNumber):
            return "\(phoneNumber)"
        case .invoice:
            return method.provider.payoutTitle
        case nil:
            return method.provider.payoutTitle
        }
    }

    fileprivate var payoutAccountDisplayTitle: String {
        guard let method = defaultPayoutMethod else { return "" }
        return method.provider.payoutTitle
    }

    fileprivate var showChangeButton: Bool {
        !availableMethods.filter({ $0.supportsPayout }).isEmpty
    }
}
#Preview {
    PayoutSelectedMethodScreen(
        vm: .init(
            paymentStatusData: .init(
                status: .active,
                chargingDay: nil,
                defaultPayinMethod: .init(
                    id: "1",
                    provider: .nordea,
                    status: .active,
                    isDefault: true,
                    details: .bankAccount(account: "3300-920123132", bank: "Nordea")
                ),
                payinMethods: [
                    .init(
                        id: "1",
                        provider: .nordea,
                        status: .active,
                        isDefault: true,
                        details: .bankAccount(account: "3300-920123132", bank: "Nordea")
                    )
                ],
                defaultPayoutMethod: .init(
                    id: "2",
                    provider: .nordea,
                    status: .active,
                    isDefault: true,
                    details: .bankAccount(account: "3300-920123132", bank: "Nordea")
                ),
                payoutMethods: [
                    .init(
                        id: "2",
                        provider: .nordea,
                        status: .active,
                        isDefault: true,
                        details: .bankAccount(account: "3300-920123132", bank: "Nordea")
                    )
                ],
                availableMethods: [
                    .init(provider: .nordea, supportsPayin: false, supportsPayout: true),
                    .init(provider: .swish, supportsPayin: false, supportsPayout: true),
                    .init(provider: .trustly, supportsPayin: true, supportsPayout: true),
                ]
            )
        )
    )
    .environmentObject(NavigationRouter())
}

#Preview("Kivra - no change button") {
    PayoutSelectedMethodScreen(
        vm: .init(
            paymentStatusData: .init(
                status: .active,
                chargingDay: nil,
                defaultPayinMethod: .init(
                    id: "1",
                    provider: .invoice,
                    status: .active,
                    isDefault: true,
                    details: .invoice(delivery: .kivra, email: nil)
                ),
                payinMethods: [
                    .init(
                        id: "1",
                        provider: .invoice,
                        status: .active,
                        isDefault: true,
                        details: .invoice(delivery: .kivra, email: nil)
                    )
                ],
                defaultPayoutMethod: .init(
                    id: "2",
                    provider: .trustly,
                    status: .active,
                    isDefault: true,
                    details: nil
                ),
                payoutMethods: [
                    .init(
                        id: "2",
                        provider: .trustly,
                        status: .active,
                        isDefault: true,
                        details: .bankAccount(account: "3300-920123132", bank: "Nordea")
                    )
                ],
                availableMethods: [
                    .init(provider: .nordea, supportsPayin: false, supportsPayout: true),
                    .init(provider: .swish, supportsPayin: false, supportsPayout: true),
                    .init(provider: .trustly, supportsPayin: true, supportsPayout: true),
                ]
            )
        )
    )
    .environmentObject(NavigationRouter())
}
