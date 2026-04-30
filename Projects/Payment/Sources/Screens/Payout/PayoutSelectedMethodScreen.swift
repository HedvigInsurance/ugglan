import SwiftUI
import hCore
import hCoreUI

public struct PayoutSelectedMethodScreen: View {
    @ObservedObject var vm: PaymentStatusViewModel
    @EnvironmentObject var router: NavigationRouter

    public init(vm: PaymentStatusViewModel) {
        self.vm = vm
    }

    private var paymentStatusData: PaymentStatusData {
        vm.paymentStatusData
    }

    public var body: some View {
        if paymentStatusData.defaultOrFirstPayoutMethod == nil {
            missingPayoutView
        } else {
            existingPayoutView
        }
    }

    private var missingPayoutView: some View {
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
            changePayoutButton(title: L10n.payoutAddPayoutMethod)
        }
        .hFormContentPosition(.center)
        .sectionContainerStyle(.transparent)
    }

    private var existingPayoutView: some View {
        hForm {
            VStack(spacing: .padding8) {
                if let displayValue = paymentStatusData.payoutAccountDisplayValue,
                    let displayTitle = paymentStatusData.payoutAccountDisplayTitle
                {
                    hSection {
                        hFloatingField(
                            value: displayValue,
                            placeholder: displayTitle,
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
            }
            .padding(.top, .padding16)
        }
        .hFormAttachToBottom {
            if paymentStatusData.payoutMethods.hasMethodInProgress {
                hSection {
                    InfoCard(text: L10n.myPaymentUpdatingMessage, type: .info)
                }
                .sectionContainerStyle(.transparent)
            }

            changePayoutButton(title: L10n.changePayoutMethodButtonLabel)
        }
    }

    @ViewBuilder
    private func changePayoutButton(title: String) -> some View {
        if paymentStatusData.showChangeButton {
            hSection {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: title),
                    {
                        router.push(PayoutRouterActions.changePayoutMethod)
                    }
                )
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

extension PaymentStatusData {
    fileprivate var payoutAccountDisplayValue: String? {
        guard let method = defaultOrFirstPayoutMethod else { return nil }
        switch method.details {
        case .bankAccount(let account, _):
            return "\(account)"
        case .swish(let phoneNumber):
            return "\(phoneNumber)"
        case .invoice:
            return method.provider.payoutTitle
        case nil:
            return nil
        }
    }

    fileprivate var payoutAccountDisplayTitle: String? {
        guard let method = defaultOrFirstPayoutMethod else { return nil }
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
