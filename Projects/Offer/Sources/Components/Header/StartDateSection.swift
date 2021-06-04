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
import hGraphQL
import Flow
import Presentation

struct StartDateSection {
    @Inject var state: OfferState
}

extension GraphQL.QuoteBundleQuery.Data.QuoteBundle {
    var isConcurrentInception: Bool {
        self.quotes.count > 1 && self.inception.asConcurrentInception != nil
    }
    
    var switcher: Bool {
        self.inception.
    }
}

extension StartDateSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let section = SectionView()
        section.dynamicStyle = .brandGrouped(
            separatorType: .custom(55),
            shouldRoundCorners: { _ in false }
        )
        let bag = DisposeBag()
        
        bag += state.dataSignal.map { $0.quoteBundle }.onValueDisposePrevious { quoteBundle in
            let row = RowView(
                title: quoteBundle.isConcurrentInception ? "Start dates" : "Start date"
            )
                        
            let iconImageView = UIImageView()
            iconImageView.image = hCoreUIAssets.calendar.image
            
            row.prepend(iconImageView)
            row.setCustomSpacing(17, after: iconImageView)
            
            let dateLabel = UILabel(value: "Today", style: .brand(.body(color: .secondary)))
            row.append(dateLabel)
            
            row.append(hCoreUIAssets.chevronRight.image)
            
            let innerBag = DisposeBag()
            
            innerBag += section.append(row).compactMap { _ in row.viewController }.onValue { viewController in
                viewController.present(
                    StartDate().withCloseButton,
                    style: .detented(.medium, .large)
                )
            }
            
            innerBag += {
                section.remove(row)
            }
            
            return innerBag
        }
        
        return (section, bag)
    }
}
