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

        let dataSignal = client.watch(
            query: GraphQL.ActivePayoutMethodsQuery(),
            cachePolicy: .returnCacheDataAndFetch
        )

        let payOutOptions = AdyenMethodsList.payOutOptions

        func presentPayOut(_ viewController: UIViewController) {
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

        bag += dataSignal.onValueDisposePrevious { data in
            let bag = DisposeBag()

            if let activeMethod = data.activePayoutMethods {
                let valueRow = RowView(
                    title: activeMethod.storedPaymentMethodsDetails.brand?.capitalized ?? ""
                )

                let valueLabel = UILabel(
                    value: L10n.PaymentScreen.creditCardMasking(activeMethod.storedPaymentMethodsDetails.lastFourDigits),
                    style: .brand(.headline(color: .tertiary))
                )
                valueRow.append(valueLabel)

                section.append(valueRow)

                let connectRow = RowView(
                    title: L10n.PaymentScreen.payOutChangePayoutButton,
                    style: .brand(.headline(color: .link))
                )

                let connectImageView = UIImageView()
                connectImageView.image = hCoreUIAssets.editIcon.image
                connectImageView.tintColor = .brand(.link)

                connectRow.append(connectImageView)

                bag += section.append(connectRow)
                    .compactMap { connectRow.viewController }
                    .onValue(presentPayOut)

                bag += {
                    section.remove(valueRow)
                    section.remove(connectRow)
                }
            } else {
                let connectRow = RowView(
                    title: L10n.PaymentScreenConnect.payOutConnectPayoutButton,
                    style: .brand(.headline(color: .link))
                )

                let connectImageView = UIImageView()
                connectImageView.image = hCoreUIAssets.circularPlus.image
                connectImageView.tintColor = .brand(.link)

                connectRow.append(connectImageView)

                bag += section.append(connectRow)
                    .compactMap { connectRow.viewController }
                    .onValue(presentPayOut)

                let footerRow = RowView()
                bag += footerRow.append(MultilineLabel(
                    value: L10n.PaymentScreen.payOutFooterNotConnected,
                    style: .brand(.footnote(color: .secondary))
                ))

                section.append(footerRow)

                bag += {
                    section.remove(connectRow)
                    section.remove(footerRow)
                }
            }

            return bag
        }

        return (section, bag)
    }
}
