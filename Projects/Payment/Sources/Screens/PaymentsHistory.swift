import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct PaymentsHistory { @Inject var client: ApolloClient }

extension PaymentsHistory: Presentable {
  func materialize() -> (UIViewController, Disposable) {
    let viewController = UIViewController()
    viewController.title = L10n.paymentHistoryTitle
    let bag = DisposeBag()

    let form = FormView()
    bag += viewController.install(form)

    let section = form.appendSection(header: nil, footer: nil)

    bag += client.watch(query: GraphQL.MyPaymentQuery())
      .onValueDisposePrevious { data -> Disposable? in let innerBag = DisposeBag()

        innerBag += data.chargeHistory.map { chargeHistory -> Disposable in
          let row = KeyValueRow()
          row.valueStyleSignal.value = .brand(.headline(color: .quartenary))

          let dateParsingFormatter = DateFormatter()
          dateParsingFormatter.dateFormat = "yyyy-MM-dd"

          if let date = dateParsingFormatter.date(from: chargeHistory.date) {
            let dateDisplayFormatter = DateFormatter()
            dateDisplayFormatter.dateFormat = "dd MMMM, yyyy"

            row.keySignal.value = dateDisplayFormatter.string(from: date)
          }

          row.valueSignal.value =
            chargeHistory.amount.fragments.monetaryAmountFragment.monetaryAmount
            .formattedAmount

          return section.append(row)
        }

        return innerBag
      }

    return (viewController, bag)
  }
}
