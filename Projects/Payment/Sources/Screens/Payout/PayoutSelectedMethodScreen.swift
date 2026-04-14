import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct PayoutSelectedMethodScreen: View {
    let data: PaymentStatusData
    @EnvironmentObject var router: NavigationRouter
    var body: some View {
        hForm {
            VStack(spacing: .padding8) {
                hSection {
                    hFloatingField(
                        value: data.payoutAccountDisplayValue,
                        placeholder: "Konto",
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

                if data.showChangeButton {
                    hSection {
                        hButton(
                            .large,
                            .primary,
                            content: .init(title: "Ändra konto"),
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
            return "Swish \(phoneNumber)"
        case .invoice:
            return method.provider.payoutTitle
        case nil:
            return method.provider.payoutTitle
        }
    }

    fileprivate var showChangeButton: Bool {
        guard let defaultPayin = payinMethods.first(where: { $0.isDefault }) else {
            return true
        }
        if case .invoice(let delivery, _) = defaultPayin.details, delivery == .kivra {
            return true
        }
        return false
    }
}

#Preview {
    PayoutSelectedMethodScreen(
        data: .init(
            status: .active,
            chargingDay: nil,
            payinMethods: [
                .init(
                    id: "1",
                    provider: .nordea,
                    status: .active,
                    isDefault: true,
                    details: .bankAccount(account: "3300-920123132", bank: "Nordea")
                )
            ],
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
    .environmentObject(NavigationRouter())
}

#Preview("Kivra - no change button") {
    PayoutSelectedMethodScreen(
        data: .init(
            status: .active,
            chargingDay: nil,
            payinMethods: [
                .init(
                    id: "1",
                    provider: .invoice,
                    status: .active,
                    isDefault: true,
                    details: .invoice(delivery: .kivra, email: nil)
                )
            ],
            payoutMethods: [
                .init(
                    id: "2",
                    provider: .trustly,
                    status: .active,
                    isDefault: true,
                    details: nil
                )
            ],
            availableMethods: [
                .init(provider: .nordea, supportsPayin: false, supportsPayout: true),
                .init(provider: .swish, supportsPayin: false, supportsPayout: true),
                .init(provider: .trustly, supportsPayin: true, supportsPayout: true),
            ]
        )
    )
    .environmentObject(NavigationRouter())
}
