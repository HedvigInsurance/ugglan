import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL

struct PayoutDetailsSection {
    @Inject var client: ApolloClient
    let urlScheme: String
}

extension PayoutDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(
            header: L10n.PaymentScreen.payoutSectionTitle,
            footer: nil
        )

        let valueRow = RowView()

        let valueLabel = UILabel()
        valueRow.append(valueLabel)

        let dataSignal = client.watch(query: GraphQL.ActivePayoutMethodsQuery())

        bag += dataSignal.onValueDisposePrevious { data in
            let bag = DisposeBag()

            if data.activePayoutMethods != nil {
                let addedRow = section.prepend(valueRow)

                bag += {
                    section.remove(addedRow)
                }
            }

            return bag
        }

        bag += dataSignal.compactMap {
            $0.activePayoutMethods?.storedPaymentMethodsDetails.brand?.capitalized
        }.onValue { value in
            valueRow.title = value
        }

        bag += dataSignal.compactMap {
            $0.activePayoutMethods?.storedPaymentMethodsDetails.lastFourDigits
        }.map { "**** \($0)" }.onValue { value in
            valueLabel.value = value
        }

        let connectRow = RowView(title: "connect")
        let payOutOptions = AdyenMethodsList.payOutOptions

        bag += section.append(connectRow).compactMap { section.viewController }.onValue { viewController in
            payOutOptions.onValue { options in
                viewController.present(
                    AdyenPayOut(adyenOptions: options, urlScheme: urlScheme).wrappedInCloseButton(),
                    style: .detented(.scrollViewContentSize(20)),
                    options: [
                        .defaults,
                        .allowSwipeDismissAlways,
                    ]
                )
            }
        }

        return (section, bag)
    }
}
