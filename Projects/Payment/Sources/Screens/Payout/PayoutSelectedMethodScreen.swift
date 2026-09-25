import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

public struct PayoutSelectedMethodScreen: View {
    @AppObservedObject var store: PaymentStore
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var paymentsNavigationVm: PaymentsNavigationViewModel
    @State private var showChangePayoutMethod = false

    public var body: some View {
        Group {
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
        .handleChangePayoutMethod(presented: $showChangePayoutMethod)
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
                if let payoutMethod = paymentStatusData.defaultOrFirstDefaultPayoutMethod {
                    hSection {
                        PaymentMethodRow(locked: payoutMethod)
                    }
                    .sectionContainerStyle(.transparent)
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
