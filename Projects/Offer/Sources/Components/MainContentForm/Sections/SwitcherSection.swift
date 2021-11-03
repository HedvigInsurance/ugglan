import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct SwitcherSection {}

extension SwitcherSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let section = SectionView(headerView: nil, footerView: nil)
        section.dynamicStyle = .brandGrouped(separatorType: .none)
        section.appendSpacing(.inbetween)

        let store: OfferStore = self.get()

        let bag = DisposeBag()

        bag += store.stateSignal
            .compactMap { $0.currentVariant?.bundle }
            .onValueDisposePrevious { quoteBundle in
                let innerBag = DisposeBag()

                section.isHidden = !quoteBundle.switcher

                if quoteBundle.switcher {
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
