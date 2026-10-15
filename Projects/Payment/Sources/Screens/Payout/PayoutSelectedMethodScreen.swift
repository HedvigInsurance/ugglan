import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

public struct PayoutSelectedMethodScreen: View {
    @AppObservedObject var store: PaymentStore
    @EnvironmentObject var router: NavigationRouter
    @Environment(PaymentsNavigationViewModel.self) var paymentsNavigationVm
    @State private var showChangePayoutMethod = false
    @State private var showChooseDefaultPayoutMethod = false

    public var body: some View {
        Group {
            if let paymentStatusData = store.paymentStatusData {
                if !paymentStatusData.displayedPayoutMethods.isEmpty {
                    existingPayoutView(paymentStatusData: paymentStatusData)
                } else if paymentStatusData.availablePayoutMethods.isEmpty {
                    missingPayinView
                } else {
                    missingPayoutView(paymentStatusData: paymentStatusData)
                }
            }
        }
        .handleChangePayoutMethod(presented: $showChangePayoutMethod)
        .detent(
            presented: $showChooseDefaultPayoutMethod,
            presentationStyle: .detent(style: [.height])
        ) {
            ChooseDefaultPaymentMethodScreen(direction: .payout)
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
                    content: .init(title: L10n.profilePaymentConnectDirectDebitButton)
                ) {
                    router.dismiss()
                    paymentsNavigationVm.showAddPaymentMethod = true
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.center)
        .sectionContainerStyle(.transparent)
    }

    private func existingPayoutView(paymentStatusData: PaymentStatusData) -> some View {
        hForm {
            VStack(spacing: .padding8) {
                hSection {
                    hRadioOptionList(paymentStatusData.displayedPayoutMethods, spacing: .padding8) { method in
                        PaymentMethodRow(readOnly: method)
                    }
                }
                hSection {
                    if paymentStatusData.payoutMethods.hasMethodInProgress {
                        InfoCard(text: L10n.paymentMethodPending, type: .neutral)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding8)
        }
        .hFormAlwaysAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    if paymentStatusData.showChangeButton {
                        hButton(.large, .secondary, content: .init(title: L10n.payoutAddPayoutMethod)) {
                            showChangePayoutMethod = true
                        }
                    }
                    if paymentStatusData.canChooseDefaultPayoutMethod {
                        hButton(.large, .ghost, content: .init(title: L10n.paymentChoosePrimaryButton)) {
                            showChooseDefaultPayoutMethod = true
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hSetScrollBounce(to: true)
        .onPullToRefresh {
            await store.fetchPaymentStatus()
        }
    }

    @ViewBuilder
    private func changePayoutButton(paymentStatusData: PaymentStatusData, title: String) -> some View {
        if paymentStatusData.showChangeButton {
            hSection {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: title)
                ) {
                    showChangePayoutMethod = true
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

extension PaymentStatusData {
    fileprivate var showChangeButton: Bool {
        !availablePayoutMethods.isEmpty
    }

    /// Falls back to the default method on its own for a response that reports it outside the list.
    fileprivate var displayedPayoutMethods: [ConnectedPaymentMethod] {
        payoutMethods.isEmpty ? [defaultOrFirstDefaultPayoutMethod].compactMap { $0 } : payoutMethods
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
                    status: .active,
                    isDefault: true,
                    method: .nordea(bankAccount: .init(account: "3300-920123132", bank: "Nordea"))
                ),
                payinMethods: [
                    .init(
                        status: .active,
                        isDefault: true,
                        method: .nordea(bankAccount: .init(account: "3300-920123132", bank: "Nordea"))
                    )
                ],
                defaultPayoutMethod: .init(
                    status: .active,
                    isDefault: true,
                    method: .nordea(
                        bankAccount: .init(
                            account: "3300-920123132",
                            bank: "Nordea LONG NAME LONG LONG LONG LONG l"
                        )
                    )
                ),
                payoutMethods: [
                    .init(
                        status: .active,
                        isDefault: true,
                        method: .nordea(bankAccount: .init(account: "3300-920123132", bank: "Nordea"))
                    ),
                    .init(
                        status: .active,
                        isDefault: false,
                        method: .swish(phoneNumber: "0701231231")
                    ),
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
                    status: .active,
                    isDefault: true,
                    method: .invoice(delivery: .kivra)
                ),
                payinMethods: [
                    .init(
                        status: .active,
                        isDefault: true,
                        method: .invoice(delivery: .kivra)
                    )
                ],
                defaultPayoutMethod: .init(
                    status: .active,
                    isDefault: true,
                    method: .trustly(bankAccount: .init(account: "2343242324", bank: "LONG bANK NAME THAT IS LONG"))
                ),
                payoutMethods: [
                    .init(
                        status: .active,
                        isDefault: true,
                        method: .trustly(bankAccount: .init(account: "3300-920123132", bank: "Nordea"))
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
