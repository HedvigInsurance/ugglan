import Adyen
import AdyenCard
import AdyenComponents
import Foundation
import PassKit
import hCore
import hCoreUI
import hGraphQL

class AdyenPaymentBuilder: PaymentComponentBuilder, APIContextAware {
    @PresentableStore var store: PaymentStore
    var apiContext: APIContext { HedvigAdyenAPIContext().apiContext }

    var formComponentStyle: FormComponentStyle {
        var formComponent = FormComponentStyle()
        formComponent.mainButtonItem.button.backgroundColor = .brand(.secondaryButtonBackgroundColor)
        formComponent.mainButtonItem.button.title.color = .brand(.secondaryButtonTextColor)
        formComponent.mainButtonItem.button.title.font = Fonts.fontFor(style: .title3)
        formComponent.mainButtonItem.button.cornerRounding = .fixed(6)
        formComponent.textField.title.font = Fonts.fontFor(style: .caption1)
        formComponent.textField.text.font = Fonts.fontFor(style: .body)
        formComponent.textField.tintColor = .brand(.primaryTintColor)
        formComponent.textField.errorColor = .brand(.destructive)
        formComponent.backgroundColor = .brand(.secondaryBackground())
        formComponent.textField.backgroundColor = .brand(.secondaryBackground())
        formComponent.hintLabel.font = Fonts.fontFor(style: .footnote)
        return formComponent
    }

    var cost: MonetaryAmount {
        store.state.monthlyNetCost
            ?? MonetaryAmount(amount: 0, currency: Localization.Locale.currentLocale.market.currencyCode)
    }

    var payment: Adyen.Payment {
        Adyen.Payment(
            amount: .init(value: Int(cost.floatAmount * 100), currencyCode: cost.currency),
            countryCode: Localization.Locale.currentLocale.market.rawValue
        )
    }

    func build(paymentMethod: StoredCardPaymentMethod) -> PaymentComponent? {
        let component = CardComponent(
            paymentMethod: paymentMethod,
            apiContext: apiContext,
            configuration: .init(
                showsStorePaymentMethodField: false
            ),
            style: formComponentStyle
        )
        component.payment = payment
        return component
    }

    func build(paymentMethod _: StoredPaymentMethod) -> PaymentComponent? { nil }

    func build(paymentMethod _: StoredBCMCPaymentMethod) -> PaymentComponent? { nil }

    func build(paymentMethod: CardPaymentMethod) -> PaymentComponent? {
        let component = CardComponent(
            paymentMethod: paymentMethod,
            apiContext: apiContext,
            configuration: .init(
                showsStorePaymentMethodField: false
            ),
            style: formComponentStyle
        )
        component.payment = payment
        return component
    }

    func build(paymentMethod _: BCMCPaymentMethod) -> PaymentComponent? { nil }

    func build(paymentMethod _: IssuerListPaymentMethod) -> PaymentComponent? { nil }

    func build(paymentMethod _: SEPADirectDebitPaymentMethod) -> PaymentComponent? { nil }

    func build(paymentMethod: MultibancoPaymentMethod) -> PaymentComponent? { nil }

    func build(paymentMethod: ApplePayPaymentMethod) -> PaymentComponent? {
        do {
            let merchantIdentifier: String

            switch Environment.current {
            case .staging: merchantIdentifier = "merchant.com.hedvig.test.app"
            case .production: merchantIdentifier = "merchant.com.hedvig.app"
            case .custom: merchantIdentifier = "merchant.com.hedvig.test.app"
            }

            var configuration: ApplePayComponent.Configuration

            if #available(iOS 15.0, *) {
                configuration = ApplePayComponent.Configuration(
                    summaryItems: [
                        PKRecurringPaymentSummaryItem(
                            label: "Hedvig",
                            amount: NSDecimalNumber(value: cost.floatAmount),
                            type: .final
                        )
                    ],
                    merchantIdentifier: merchantIdentifier
                )
            } else {
                configuration = ApplePayComponent.Configuration(
                    summaryItems: [
                        .init(
                            label: "Hedvig",
                            amount: NSDecimalNumber(value: cost.floatAmount),
                            type: .final
                        )
                    ],
                    merchantIdentifier: merchantIdentifier
                )
            }

            return try ApplePayComponent(
                paymentMethod: paymentMethod,
                apiContext: apiContext,
                payment: payment,
                configuration: configuration
            )
        } catch {
            print("Failed to instantiate ApplePayComponent because of error: \(error.localizedDescription)")
            return nil
        }
    }

    func build(paymentMethod _: WeChatPayPaymentMethod) -> PaymentComponent? { nil }

    func build(paymentMethod _: QiwiWalletPaymentMethod) -> PaymentComponent? { nil }

    func build(paymentMethod _: MBWayPaymentMethod) -> PaymentComponent? { nil }

    func build(paymentMethod _: BLIKPaymentMethod) -> PaymentComponent? { nil }

    func build(paymentMethod: PaymentMethod) -> PaymentComponent? {
        EmptyPaymentComponent(paymentMethod: paymentMethod)
    }
    func build(paymentMethod: DokuPaymentMethod) -> PaymentComponent? { nil }
    func build(paymentMethod: EContextPaymentMethod) -> PaymentComponent? { nil }
    func build(paymentMethod: GiftCardPaymentMethod) -> PaymentComponent? { nil }
    func build(paymentMethod: BoletoPaymentMethod) -> PaymentComponent? { nil }
    func build(paymentMethod: AffirmPaymentMethod) -> PaymentComponent? { nil }
    func build(paymentMethod: OXXOPaymentMethod) -> PaymentComponent? { nil }
    func build(paymentMethod: BACSDirectDebitPaymentMethod) -> PaymentComponent? { nil }
    func build(paymentMethod: ACHDirectDebitPaymentMethod) -> PaymentComponent? { nil }
}
