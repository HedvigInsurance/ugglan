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

struct DetailsSection {
    @Inject var state: OfferState
}

extension Array where Element: Disposable {
    var disposable: Disposable {
        DisposeBag(self)
    }
}

extension DetailsSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let section = SectionView(headerView: UILabel(value: "Your Details", style: .default), footerView: nil)
        let bag = DisposeBag()
        
        bag += state.quotesSignal.onValueDisposePrevious { quotes in
            quotes.map { quote -> DisposeBag in
                let innerBag = DisposeBag()
                
                let headerContainer = UIStackView()
                headerContainer.addArrangedSubview(UILabel(value: "Innboforsikring", style: .brand(.callout(color: .tertiary))))
                
                let innerSection = SectionView(headerView: headerContainer, footerView: nil)
                section.append(innerSection)
                
                innerBag += {
                    innerSection.removeFromSuperview()
                }
                
                innerBag += quote.detailsTable.map { item in
                    let row = RowView(title: item.label)
                    innerSection.append(row)
                    
                    let valueLabel = UILabel(value: item.value, style: .brand(.body(color: .secondary)))
                    row.append(valueLabel)
                    
                    return Disposer {
                        innerSection.remove(row)
                    }
                }
                
                return innerBag
            }.disposable
        }
                
        return (section, bag)
    }
}
