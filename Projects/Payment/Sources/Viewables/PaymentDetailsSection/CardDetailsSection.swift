import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct CardDetailsSection {
    @Inject var giraffe: hGiraffe
    let urlScheme: String
}

extension CardDetailsSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()

        let section = SectionView(header: L10n.myPaymentCardRowLabel, footer: nil)

        let dataSignal = giraffe.client.watch(
            query: GiraffeGraphQL.ActivePaymentMethodsQuery(),
            cachePolicy: .returnCacheDataAndFetch
        )

        let payInOptions = AdyenMethodsList.payInOptions

        func presentPayIn(_ viewController: UIViewController) {
            payInOptions.onValue { options in
                viewController.present(
                    AdyenPayIn(adyenOptions: options, urlScheme: urlScheme)
                        .journey({ _ in
                            DismissJourney()
                        })
                        .withJourneyDismissButton
                        .setStyle(.detented(.medium, .large))
                        .setOptions([.defaults, .allowSwipeDismissAlways])
                )
                .onValue { _ in

                }
            }
        }

        bag += dataSignal.onValueDisposePrevious { data in
            let bag = DisposeBag()

            if let activeMethod = data.activePaymentMethodsV2 {
                var valueRowTitle: String {
                    if let card = activeMethod.asStoredCardDetails {
                        return card.brand?.capitalized ?? ""
                    } else if let thirdParty = activeMethod.asStoredThirdPartyDetails {
                        return thirdParty.type.capitalized
                    }

                    return ""
                }

                let valueRow = RowView(
                    title: valueRowTitle
                )

                var valueLabelTitle: String {
                    if let card = activeMethod.asStoredCardDetails {
                        return L10n.PaymentScreen.creditCardMasking(
                            card.lastFourDigits
                        )
                    } else if let thirdParty = activeMethod.asStoredThirdPartyDetails {
                        return thirdParty.name
                    }

                    return ""
                }

                let valueLabel = UILabel(
                    value: valueLabelTitle,
                    style: .brand(.headline(color: .tertiary))
                )
                valueRow.append(valueLabel)

                section.append(valueRow)

                let connectRow = RowView(
                    title: L10n.myPaymentDirectDebitReplaceButton,
                    style: .brand(.headline(color: .link))
                )

                let connectImageView = UIImageView()
                connectImageView.image = hCoreUIAssets.editIcon.image
                connectImageView.tintColor = .brand(.link)

                connectRow.append(connectImageView)

                bag += section.append(connectRow).compactMap { connectRow.viewController }
                    .onValue(presentPayIn)

                bag += {
                    section.remove(valueRow)
                    section.remove(connectRow)
                }
            } else {
                let connectRow = RowView(
                    title: L10n.myPaymentDirectDebitButton,
                    style: .brand(.headline(color: .link))
                )

                let connectImageView = UIImageView()
                connectImageView.image = hCoreUIAssets.circularPlus.image
                connectImageView.tintColor = .brand(.link)

                connectRow.append(connectImageView)

                bag += section.append(connectRow).compactMap { connectRow.viewController }
                    .onValue(presentPayIn)

                bag += { section.remove(connectRow) }
            }

            return bag
        }

        return (section, bag)
    }
}
