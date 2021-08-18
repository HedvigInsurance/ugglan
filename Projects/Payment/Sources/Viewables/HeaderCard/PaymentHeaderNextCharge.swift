import Apollo
import Flow
import Form
import Foundation
import UIKit
import hCore
import hGraphQL

struct PaymentHeaderNextCharge { @Inject var client: ApolloClient }

extension PaymentHeaderNextCharge: Viewable {
  func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
    let view = UIView()
    let bag = DisposeBag()
    view.layer.cornerRadius = 5

    let contentContainer = UIStackView()
    contentContainer.layoutMargins = UIEdgeInsets(inset: 5)
    contentContainer.isLayoutMarginsRelativeArrangement = true
    contentContainer.distribution = .equalSpacing
    view.addSubview(contentContainer)

    let label = UILabel(value: "", style: TextStyle.brand(.subHeadline(color: .primary)))
    contentContainer.addArrangedSubview(label)

    contentContainer.snp.makeConstraints { make in make.top.bottom.leading.trailing.equalToSuperview() }

    bag += client.watch(query: GraphQL.MyPaymentQuery()).map { $0.nextChargeDate }
      .onValue { nextChargeDate in
        if let nextChargeDate = nextChargeDate {
          let dateParsingFormatter = DateFormatter()
          dateParsingFormatter.dateFormat = "yyyy-MM-dd"

          if let date = dateParsingFormatter.date(from: nextChargeDate) {
            let dateDisplayFormatter = DateFormatter()
            dateDisplayFormatter.dateFormat = "dd MMMM"
            label.value = dateDisplayFormatter.string(from: date)
          }

          view.backgroundColor = .brand(.primaryBackground())
        } else {
          label.value = L10n.paymentsCardNoStartdate
          view.backgroundColor = .brand(.regularCaution)
        }
      }

    return (view, bag)
  }
}
