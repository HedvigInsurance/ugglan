import Apollo
import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct CardDetailsSection {
  @Inject var client: ApolloClient
  let urlScheme: String
}

extension CardDetailsSection: Viewable {
  func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
    let bag = DisposeBag()

    let section = SectionView(header: L10n.myPaymentCardRowLabel, footer: nil)

    let dataSignal = client.watch(
      query: GraphQL.ActivePaymentMethodsQuery(),
      cachePolicy: .returnCacheDataAndFetch
    )

    let payInOptions = AdyenMethodsList.payInOptions

    func presentPayIn(_ viewController: UIViewController) {
      payInOptions.onValue { options in
        viewController.present(
          AdyenPayIn(adyenOptions: options, urlScheme: urlScheme).wrappedInCloseButton(),
          style: .detented(.scrollViewContentSize),
          options: [.defaults, .allowSwipeDismissAlways]
        )
      }
    }

    bag += dataSignal.onValueDisposePrevious { data in let bag = DisposeBag()

      if let activeMethod = data.activePaymentMethods {
        let valueRow = RowView(
          title: activeMethod.storedPaymentMethodsDetails.brand?.capitalized ?? ""
        )

        let valueLabel = UILabel(
          value: L10n.PaymentScreen.creditCardMasking(
            activeMethod.storedPaymentMethodsDetails.lastFourDigits
          ),
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
