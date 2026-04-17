import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct PayoutSelectedMethodScreen: View {
    @ObservedObject var vm: PaymentStatusViewModel
    @EnvironmentObject var paymentsNavigationViewModel: PaymentsNavigationViewModel
    @EnvironmentObject var router: NavigationRouter
    let withCloseButton: Bool
    var body: some View {
        if vm.paymentStatusData.defaultPayoutMethod == nil {
            hForm {
                hSection {
                    InfoCard(
                        text: "It looks like you are missing payout method. Add it so we can payout to you",
                        type: .info
                    )
                }
                .padding(.bottom, .padding8)
            }
            .hFormAttachToBottom {
                hSection {
                    hButton(
                        .large,
                        .primary,
                        content: .init(title: "Add payout method"),
                        {
                            paymentsNavigationViewModel.showPayoutSetup = true
                        }
                    )
                }
            }
            .hFormContentPosition(.bottom)
            .sectionContainerStyle(.transparent)
        } else {
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
                }
                .padding(.top, .padding16)
            }
            .hFormAttachToBottom {
                if vm.paymentStatusData.payoutMethods.hasMethodInProgress {
                    hSection {
                        InfoCard(text: L10n.myPaymentUpdatingMessage, type: .info)
                    }
                    .sectionContainerStyle(.transparent)
                }
                if withCloseButton {
                    hSection {
                        hCloseButton { [weak router] in
                            router?.dismiss()
                        }
                    }
                    .sectionContainerStyle(.transparent)
                } else {
                    if vm.paymentStatusData.showChangeButton {
                        hSection {
                            hButton(
                                .large,
                                .primary,
                                content: .init(title: L10n.changePayoutMethodButtonLabel),
                                {
                                    paymentsNavigationViewModel.showPayoutSetup = true
                                }
                            )
                        }
                        .sectionContainerStyle(.transparent)
                    }
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
        !availablePayoutMethods.isEmpty
    }
}
#Preview {
    PayoutSelectedMethodScreen(
        vm: .init(
            paymentStatusData: .init(
                status: .active,
                chargingDay: nil,
                defaultPayinMethod: .init(
                    provider: .nordea,
                    status: .active,
                    isDefault: true,
                    details: .bankAccount(account: "3300-920123132", bank: "Nordea")
                ),
                payinMethods: [
                    .init(
                        provider: .nordea,
                        status: .active,
                        isDefault: true,
                        details: .bankAccount(account: "3300-920123132", bank: "Nordea")
                    )
                ],
                defaultPayoutMethod: .init(
                    provider: .nordea,
                    status: .active,
                    isDefault: true,
                    details: .bankAccount(account: "3300-920123132", bank: "Nordea")
                ),
                payoutMethods: [
                    .init(
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
        ),
        withCloseButton: false
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
                    provider: .invoice,
                    status: .active,
                    isDefault: true,
                    details: .invoice(delivery: .kivra, email: nil)
                ),
                payinMethods: [
                    .init(
                        provider: .invoice,
                        status: .active,
                        isDefault: true,
                        details: .invoice(delivery: .kivra, email: nil)
                    )
                ],
                defaultPayoutMethod: .init(
                    provider: .trustly,
                    status: .active,
                    isDefault: true,
                    details: nil
                ),
                payoutMethods: [
                    .init(
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
        ),
        withCloseButton: false
    )
    .environmentObject(NavigationRouter())
}

#Preview("PayoutSelectedMethodScreen - no default payout") {
    PayoutSelectedMethodScreen(
        vm: .init(
            paymentStatusData: .init(
                status: .active,
                chargingDay: nil,
                defaultPayinMethod: .init(
                    provider: .invoice,
                    status: .active,
                    isDefault: true,
                    details: .invoice(delivery: .kivra, email: nil)
                ),
                payinMethods: [
                    .init(
                        provider: .invoice,
                        status: .active,
                        isDefault: true,
                        details: .invoice(delivery: .kivra, email: nil)
                    )
                ],
                defaultPayoutMethod: nil,
                payoutMethods: [],
                availableMethods: [
                    .init(provider: .nordea, supportsPayin: false, supportsPayout: true),
                    .init(provider: .swish, supportsPayin: false, supportsPayout: true),
                    .init(provider: .trustly, supportsPayin: true, supportsPayout: true),
                ]
            )
        ),
        withCloseButton: false
    )
    .environmentObject(NavigationRouter())
    .environmentObject(PaymentsNavigationViewModel())
}
