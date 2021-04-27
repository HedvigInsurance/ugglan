//
//  DetailsSection.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-04-21.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Form
import hCore
import hCoreUI
import Flow
import Presentation

struct CoverageSection {
    @Inject var state: OfferState
}

extension CoverageSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let section = SectionView(headerView: UILabel(value: "Coverage", style: .default), footerView: nil)
        section.dynamicStyle = .brandGrouped(separatorType: .none)
        
        let bag = DisposeBag()
        
        bag += state.quotesSignal.onValueDisposePrevious { quotes in
            let innerBag = DisposeBag()
            
            let innerSection = SectionView()
            innerSection.dynamicStyle = .brandGrouped(separatorType: .standard, shouldRoundCorners: { _ in false })
            
            if quotes.count > 1 {
                let label = MultilineLabel(value: "Read the full coverage of your insurances below.", style: .brand(.body(color: .secondary)))
                let labelInset = UIEdgeInsets(horizontalInset: 15, verticalInset: 0) + UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
                innerBag += section.append(label.insetted(labelInset))
                
                section.append(innerSection)
                
                innerBag += {
                    innerSection.removeFromSuperview()
                }
            }
            
            innerBag += quotes.map { (quote) -> DisposeBag in
                let innerBag = DisposeBag()
                
                if quotes.count > 1 {
                    let row = RowView(title: quote.displayName)
                    row.append(hCoreUIAssets.chevronRight.image)
                    
                    innerBag += innerSection.append(row).onValue {
                        section.viewController?.present(
                            QuoteCoverage(quote: quote).withCloseButton,
                            style: .detented(.large),
                            options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
                        )
                    }
                    
                    innerBag += {
                        innerSection.remove(row)
                    }
                } else {
                    innerBag += section.append(SingleQuoteCoverage(quote: quote))
                }
                
                return innerBag
            }
            
            return innerBag
        }
                
        return (section, bag)
    }
}
