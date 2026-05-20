import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct PayinSelectedMethodScreen: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var paymentsNavigationVm: PaymentsNavigationViewModel

    public var body: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentStatusData
            }
        ) { paymentStatusData in
            if let paymentStatusData {
                if paymentStatusData.defaultOrFirstDefaultPayinMethod != nil {
                    existingPayinView(paymentStatusData: paymentStatusData)
                } else if paymentStatusData.availablePayinMethods.isEmpty {
                    missingPayinOptionsView
                } else {
                    missingPayinView(paymentStatusData: paymentStatusData)
                }
            }
        }
    }

    private func missingPayinView(paymentStatusData: PaymentStatusData) -> some View {
        hForm {
            hSection {
                VStack(spacing: .padding16) {
                    hCoreUIAssets.infoFilled.view
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(hSignalColor.Blue.element)

                    hText("You haven't added a payin method yet")  //L10n.payinMissingInfo
                        .multilineTextAlignment(.center)
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormAttachToBottom {
            changePayinButton(paymentStatusData: paymentStatusData, title: "Add payin method")  //L10n.payinAddPayinMethod
        }
        .hFormContentPosition(.center)
        .sectionContainerStyle(.transparent)
    }

    private var missingPayinOptionsView: some View {
        hForm {
            hSection {
                VStack(spacing: .padding16) {
                    hCoreUIAssets.infoFilled.view
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(hSignalColor.Blue.element)
                    VStack(spacing: .padding2) {
                        hText("No payin method available")  //L10n.payinNoPayinOptionsTitle
                            .multilineTextAlignment(.center)
                        hText("Contact us to set up a payin method")  //L10n.payinNoPayinOptionsSubtitle
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.center)
        .sectionContainerStyle(.transparent)
    }

    private func existingPayinView(paymentStatusData: PaymentStatusData) -> some View {
        hForm {
            VStack(spacing: .padding8) {
                if let displayValue = paymentStatusData.payinAccountDisplayValue,
                    let displayTitle = paymentStatusData.payinAccountDisplayTitle
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
            if paymentStatusData.payinMethods.hasMethodInProgress {
                hSection {
                    InfoCard(text: L10n.myPaymentUpdatingMessage, type: .info)
                }
                .sectionContainerStyle(.transparent)
            }

            changePayinButton(
                paymentStatusData: paymentStatusData,
                title: "Change payin method"  //L10n.changePayinMethodButtonLabel
            )
        }
    }

    @ViewBuilder
    private func changePayinButton(paymentStatusData: PaymentStatusData, title: String) -> some View {
        if paymentStatusData.showPayinChangeButton {
            hSection {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: title),
                    { [weak router] in
                        router?.push(PayinRouterActions.changePayinMethod)
                    }
                )
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

extension PaymentStatusData {
    fileprivate var payinAccountDisplayValue: String? {
        guard let method = defaultOrFirstDefaultPayinMethod else { return nil }
        switch method.details {
        case .bankAccount(let account, _):
            return "\(account)"
        case .swish(let phoneNumber):
            return "\(phoneNumber)"
        case .invoice:
            return method.provider.payinTitle
        case nil:
            return ""
        }
    }

    fileprivate var payinAccountDisplayTitle: String? {
        guard let method = defaultOrFirstDefaultPayinMethod else { return nil }
        guard let details = method.details else { return method.provider.payinTitle }
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
            return method.provider.payinTitle + " - " + sufix
        }
        return method.provider.payinTitle
    }

    fileprivate var showPayinChangeButton: Bool {
        !availablePayinMethods.isEmpty
    }
}

#Preview {
    PayinSelectedMethodScreen()
        .environmentObject(NavigationRouter())
        .onAppear {
            let store: PaymentStore = globalPresentableStoreContainer.get()
            store.send(
                .setPaymentStatus(
                    data: .init(
                        status: .active,
                        chargingDay: 27,
                        defaultPayinMethod: .init(
                            provider: .trustly,
                            status: .active,
                            isDefault: true,
                            details: .bankAccount(account: "*****123", bank: "Nordea")
                        ),
                        payinMethods: [
                            .init(
                                provider: .trustly,
                                status: .active,
                                isDefault: true,
                                details: .bankAccount(account: "*****123", bank: "Nordea")
                            )
                        ],
                        defaultPayoutMethod: nil,
                        payoutMethods: [],
                        availableMethods: [
                            .init(provider: .trustly, supportsPayin: true, supportsPayout: true),
                            .init(provider: .invoice, supportsPayin: true, supportsPayout: false),
                        ]
                    )
                )
            )
        }
}

#Preview("PayinSelectedMethodScreen - no default payin") {
    PayinSelectedMethodScreen()
        .environmentObject(NavigationRouter())
        .onAppear {
            let store: PaymentStore = globalPresentableStoreContainer.get()
            store.send(
                .setPaymentStatus(
                    data: .init(
                        status: .needsSetup,
                        chargingDay: nil,
                        defaultPayinMethod: nil,
                        payinMethods: [],
                        defaultPayoutMethod: nil,
                        payoutMethods: [],
                        availableMethods: [
                            .init(provider: .trustly, supportsPayin: true, supportsPayout: true),
                            .init(provider: .invoice, supportsPayin: true, supportsPayout: false),
                        ]
                    )
                )
            )
        }
}
