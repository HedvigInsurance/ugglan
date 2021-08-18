import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct MultiQuoteCoverage {
  let quotes: [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote]
}

extension MultiQuoteCoverage: Presentable {
  func materialize() -> (SectionView, Disposable) {
    let bag = DisposeBag()

    let section = SectionView(
      headerView: {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .vertical

        bag += stackView.addArranged(
          MultilineLabel(
            value:
              L10n.contractCoverageMoreInfo,
            style: .brand(.title3(color: .primary))
          )
        )

        bag += stackView.addArranged(
          MultilineLabel(
            value:
              L10n.OfferScreenMULTIPLEINSURANCES.coverageParagraph,
            style: .brand(.body(color: .secondary))
          )
        )

        return stackView
      }(),
      footerView: nil
    )
    section.dynamicStyle = .brandGroupedInset(separatorType: .standard)

    bag += quotes.map { quote -> DisposeBag in
      let innerBag = DisposeBag()
      let row = RowView(title: quote.displayName)
      row.append(hCoreUIAssets.chevronRight.image)

      innerBag += section.append(row)
        .onValue {
          section.viewController?
            .present(
              QuoteCoverage(quote: quote).withCloseButton,
              style: .detented(.large),
              options: [
                .defaults, .prefersLargeTitles(true),
                .largeTitleDisplayMode(.always),
              ]
            )
        }

      innerBag += {
        row.removeFromSuperview()
      }
      return innerBag
    }

    return (section, bag)
  }
}
