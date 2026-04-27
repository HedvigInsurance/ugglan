import SwiftUI
import hCore
import hCoreUI

public struct PayoutSelectedMethodScreen: View {
    @ObservedObject var vm: PaymentStatusViewModel
    @EnvironmentObject var router: NavigationRouter

    public init(vm: PaymentStatusViewModel) {
        self.vm = vm
    }

    public var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        if vm.paymentStatusData.defaultOrFirstPayoutMethod == nil {
            hForm {
                hSection {
                    VStack(spacing: .padding16) {
                        hCoreUIAssets.infoFilled.view
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(hSignalColor.Blue.element)

                        hText(L10n.payoutMissingInfo)
                            .multilineTextAlignment(.center)
                    }
                }
                .sectionContainerStyle(.transparent)
            }
            .hFormAttachToBottom {
                hSection {
                    hButton(
                        .large,
                        .primary,
                        content: .init(title: L10n.payoutAddPayoutMethod),
                        {
                            router.push(PayoutRouterActions.changePayoutMethod)
                        }
                    )
                }
            }
            .hFormContentPosition(.center)
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

                if vm.paymentStatusData.showChangeButton {
                    hSection {
                        hButton(
                            .large,
                            .primary,
                            content: .init(title: L10n.changePayoutMethodButtonLabel),
                            {
                                router.push(PayoutRouterActions.changePayoutMethod)
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
        guard let method = defaultOrFirstPayoutMethod else { return "" }
        switch method.details {
        case .bankAccount(let account, _):
            return "\(account)"
        case .swish(let phoneNumber):
            return "\(phoneNumber)"
        case .invoice:
            return method.provider.payoutTitle
        case nil:
            return "----"
        }
    }

    fileprivate var payoutAccountDisplayTitle: String {
        guard let method = defaultOrFirstPayoutMethod else { return "" }
        guard let details = method.details else { return method.provider.payoutTitle }
        let sufix: String? = {
            switch details {
            case .invoice:
                return nil
            case .swish:
                return nil
            case .bankAccount(_, let bank):
                return bank
            }
        }()
        if let sufix {
            return method.provider.payoutTitle + " - " + sufix
        }
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
                    details: .bankAccount(account: "3300-920123132", bank: "Nordea LONG NAME LONG LONG LONG LONG l")
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
                    details: .bankAccount(account: "2343242324", bank: "LONG bANK NAME THAT IS LONG")
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
        )
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
        )
    )
    .environmentObject(NavigationRouter())
}
