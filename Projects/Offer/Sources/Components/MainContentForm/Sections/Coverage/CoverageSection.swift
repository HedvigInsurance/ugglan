import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct CoverageSection {
  @Inject var state: OldOfferState
}

extension CoverageSection: Presentable {
  func materialize() -> (SectionView, Disposable) {
    let section = SectionView(headerView: nil, footerView: nil)
    section.dynamicStyle = .brandGrouped(separatorType: .none)

    let bag = DisposeBag()

    bag += state.quotesSignal.onValueDisposePrevious { quotes in
      let innerBag = DisposeBag()

      if quotes.count > 1 {
        innerBag += section.append(MultiQuoteCoverage(quotes: quotes))
      } else if let quote = quotes.first {
        innerBag += section.append(SingleQuoteCoverage(quote: quote), options: [.autoRemove])
      }

      return innerBag
    }

    bag += state
      .dataSignal
      .compactMap { $0.quoteBundle }
      .onValueDisposePrevious { quoteBundle in
        let innerBag = DisposeBag()

        let hasConcurrentInception =
          quoteBundle.inception.asConcurrentInception?.currentInsurer != nil
        let hasIndependentInceptions =
          quoteBundle.inception.asIndependentInceptions?.inceptions
          .compactMap { $0.currentInsurer }.count ?? 0 > 0

        if hasConcurrentInception || hasIndependentInceptions {
          innerBag += section.append(
            CurrentInsurerSection(quoteBundle: quoteBundle),
            options: [.autoRemove]
          )
        }

        return innerBag
      }

    return (section, bag)
  }
}
