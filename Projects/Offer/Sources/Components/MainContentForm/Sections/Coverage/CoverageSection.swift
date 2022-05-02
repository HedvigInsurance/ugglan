import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import SwiftUI

struct CoverageSection {}

extension CoverageSection: View {
    var body: some View {
        VStack {
            PresentableStoreLens(
                OfferStore.self,
                getter: { $0.currentVariant?.bundle.quotes ?? [] }
            ) { quotes in
                ForEach(quotes) { quote in
                    SingleQuoteCoverage(quote: quote)
                }
            }
        }
    }
}

extension CoverageSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let section = SectionView(headerView: nil, footerView: nil)
        section.dynamicStyle = .brandGrouped(separatorType: .none)

        let store: OfferStore = self.get()

        let bag = DisposeBag()

        bag += store.stateSignal
            .compactMap { $0.currentVariant?.bundle.quotes }
            .onValueDisposePrevious { quotes in
                let innerBag = DisposeBag()

                UIView.performWithoutAnimation {
                    if quotes.count > 1 {
                        innerBag += section.append(MultiQuoteCoverage(quotes: quotes), options: [.autoRemove])
                    } else if let quote = quotes.first {
                        innerBag += section.append(SingleQuoteCoverage(quote: quote), options: [.autoRemove])
                    }
                }

                return innerBag
            }

        return (section, bag)
    }
}
