import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct PaymentDetailsSection {
    @Inject var giraffe: hGiraffe
    let presentingViewController: UIViewController

    init(presentingViewController: UIViewController) { self.presentingViewController = presentingViewController }
}

extension PaymentDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let dataSignal = giraffe.client.watch(
            query: GiraffeGraphQL.MyPaymentQuery(
                locale: Localization.Locale.currentLocale.asGraphQLLocale()
            ),
            cachePolicy: .returnCacheDataAndFetch
        )

        let section = SectionView(header: L10n.myPaymentPaymentRowLabel, footer: nil)

        let grossPriceRow = KeyValueRow()
        grossPriceRow.keySignal.value = L10n.profilePaymentPriceLabel
        grossPriceRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))

        bag += dataSignal.map { $0.chargeEstimation.subscription.fragments.monetaryAmountFragment.monetaryAmount
        }
            .map { amount in
                L10n.profilePaymentPrice(amount.formattedAmountWithoutSymbol)
            }
            .bindTo(grossPriceRow.valueSignal)

        bag += section.append(grossPriceRow)

        let discountRow = KeyValueRow()
        discountRow.keySignal.value = L10n.profilePaymentDiscountLabel
        discountRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))

        bag += dataSignal.map {
            $0.chargeEstimation.discount.fragments.monetaryAmountFragment.monetaryAmount
        }
            .map { amount in
                L10n.profilePaymentDiscount(amount.formattedAmountWithoutSymbol)
            }
            .bindTo(discountRow.valueSignal)

        bag += section.append(discountRow)

        let netPriceRow = KeyValueRow()
        netPriceRow.keySignal.value = L10n.profilePaymentFinalCostLabel
        netPriceRow.valueStyleSignal.value = .brand(.headline(color: .quartenary))

        bag += dataSignal.map {
            $0.chargeEstimation.charge.fragments.monetaryAmountFragment.monetaryAmount
        }
            .map { amount in
                L10n.profilePaymentFinalCost(amount.formattedAmountWithoutSymbol)
            }
            .bindTo(netPriceRow.valueSignal)

        bag += section.append(netPriceRow)

        let applyDiscountButtonRow = ButtonRow(
            text: L10n.referralAddcouponHeadline,
            style: .brand(.headline(color: .link))
        )

        bag += applyDiscountButtonRow.onSelect.onValue { _ in let applyDiscount = ApplyDiscount()

            bag += applyDiscount.didRedeemValidCodeSignal.onValue { result in
                self.giraffe.client.fetch(
                    query: GiraffeGraphQL.MyPaymentQuery(
                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
                    ),
                    cachePolicy: .fetchIgnoringCacheData
                ).onValue { _ in
                    // only refetching to update cache
                }

                if let costFragment = result.cost?.fragments.costFragment {
                    NotificationCenter.default.post(name: .costDidUpdate, object: costFragment)
                }

                let alert = Alert(
                    title: L10n.discountRedeemSuccess,
                    message: L10n.discountRedeemSuccessBody,
                    actions: [Alert.Action(title: L10n.discountRedeemSuccessButton) {}]
                )
                self.presentingViewController.present(alert)
            }

            self.presentingViewController.present(
                applyDiscount.wrappedInCloseButton(),
                style: .detented(.scrollViewContentSize, .large),
                options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
            )
        }

        bag += section.append(applyDiscountButtonRow)

        let hasAppliedDiscount = dataSignal.map { !$0.chargeEstimation.discount.fragments.monetaryAmountFragment.monetaryAmount.floatAmount.isZero
        }
        bag += hasAppliedDiscount.bindTo(applyDiscountButtonRow.isHiddenSignal)

        return (section, bag)
    }
}
