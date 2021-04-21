//
//  StartDateSection.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-04-19.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Form
import hCore
import hCoreUI
import Flow
import Presentation

struct StartDateSection {
    @Inject var state: OfferState
}

extension StartDateSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let section = SectionView()
        section.dynamicStyle = .brandGrouped(
            separatorType: .custom(55),
            shouldRoundCorners: { _ in false }
        )
        let bag = DisposeBag()
        
        func appendRow() {
            let row = RowView(title: "Start date")
                        
            let iconImageView = UIImageView()
            iconImageView.image = hCoreUIAssets.calendar.image
            
            row.prepend(iconImageView)
            row.setCustomSpacing(17, after: iconImageView)
            
            let dateLabel = UILabel(value: "Today", style: .brand(.body(color: .secondary)))
            row.append(dateLabel)
            
            row.append(hCoreUIAssets.chevronRight.image)
            
            bag += section.append(row).onValue { _ in
                // todo
            }
        }
        
        bag += state.dataSignal.map { $0.quoteBundle.quotes }.onValue { quotes in
            quotes.forEach { quote in
                appendRow()
            }
        }
        
        return (section, bag)
    }
}
