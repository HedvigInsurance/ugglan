import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

public struct PayoutSelectedMethodScreen: View {
    @AppObservedObject var store: PaymentStore
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var paymentsNavigationVm: PaymentsNavigationViewModel

    public var body: some View {
        if let paymentStatusData = store.paymentStatusData {
            if paymentStatusData.defaultOrFirstDefaultPayoutMethod != nil {
                existingPayoutView(paymentStatusData: paymentStatusData)
            } else if paymentStatusData.availablePayoutMethods.isEmpty {
                missingPayinView
            } else {
                missingPayoutView(paymentStatusData: paymentStatusData)
            }
        }
    }

    private func missingPayoutView(paymentStatusData: PaymentStatusData) -> some View {
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
            changePayoutButton(paymentStatusData: paymentStatusData, title: L10n.payoutAddPayoutMethod)
        }
        .hFormContentPosition(.center)
        .sectionContainerStyle(.transparent)
    }

    private var missingPayinView: some View {
        hForm {
            hSection {
                VStack(spacing: .padding16) {
                    hCoreUIAssets.infoFilled.view
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(hSignalColor.Blue.element)
                    VStack(spacing: .padding2) {
                        hText(L10n.payoutNoPayoutOptionsTitle)
                            .multilineTextAlignment(.center)
                        hText(L10n.payoutNoPayoutOptionsSubtitle)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormAttachToBottom {
            hSection {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: L10n.profilePaymentConnectDirectDebitButton),
                    { [weak router, weak paymentsNavigationVm] in
                        router?.dismiss()
                        paymentsNavigationVm?.connectPaymentVm.set()
                    }
                )
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.center)
        .sectionContainerStyle(.transparent)
    }

    private func existingPayoutView(paymentStatusData: PaymentStatusData) -> some View {
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

            changePayoutButton(paymentStatusData: paymentStatusData, title: L10n.changePayoutMethodButtonLabel)
        }
    }

    @ViewBuilder
    private func changePayoutButton(paymentStatusData: PaymentStatusData, title: String) -> some View {
        if paymentStatusData.showChangeButton {
            hSection {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: title),
                    { [weak router] in
                        router?.push(PayoutRouterActions.changePayoutMethod)
                    }
                )
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

extension PaymentStatusData {
    fileprivate var payoutAccountDisplayValue: String? {
        guard let method = defaultOrFirstDefaultPayoutMethod else { return nil }
        switch method.details {
        case .bankAccount(let account, _):
            return "\(account)"
        case .swish(let phoneNumber):
            return "\(phoneNumber)"
        case .invoice:
            return method.provider.payoutTitle
        case nil:
            return ""
        }
    }

    fileprivate var payoutAccountDisplayTitle: String? {
        guard let method = defaultOrFirstDefaultPayoutMethod else { return nil }
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
    PayoutSelectedMethodScreen()
        .environmentObject(NavigationRouter())
        .onAppear {
            let store: PaymentStore = globalAppStateContainer.get()
            store.paymentStatusData = .init(
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
                    details: .bankAccount(
                        account: "3300-920123132",
                        bank: "Nordea LONG NAME LONG LONG LONG LONG l"
                    )
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
                ],
                missingConnection: .payout,
                layout: .other
            )
        }
}

#Preview("Kivra - no change button") {
    PayoutSelectedMethodScreen()
        .environmentObject(NavigationRouter())
}

#Preview("PayoutSelectedMethodScreen - no default payout") {
    PayoutSelectedMethodScreen()
        .environmentObject(NavigationRouter())
        .onAppear {
            let store: PaymentStore = globalAppStateContainer.get()
            store.paymentStatusData = .init(
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
                ],
                missingConnection: nil,
                layout: .other
            )
        }
}
