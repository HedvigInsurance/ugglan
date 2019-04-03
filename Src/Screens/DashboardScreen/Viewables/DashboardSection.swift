//
//  DashboardSection.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-03-31.
//

import Flow
import Form
import Foundation
import UIKit

struct DashboardSection {}

extension DashboardSection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.edgeInsets = UIEdgeInsets(
            top: 0,
            left: 25,
            bottom: 0,
            right: 25
        )
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let title = UILabel(value: "Ditt skydd", style: .rowTitle)
        stackView.addArrangedSubview(title)
        
        let referralSpacing = Spacing(height: 10)
        let rowSpacing = Spacing(height: 8)
        
        bag += stackView.addArranged(referralSpacing)
        
        let coinsuredRow = CoinsuredRow()
        bag += stackView.addArranged(coinsuredRow)
        
        bag += stackView.addArranged(rowSpacing)
        
        let homeRow = MyProtectionView(mode: .home)
        bag += stackView.addArranged(homeRow)
        
        bag += stackView.addArranged(rowSpacing)
        
        let itemsRow = MyProtectionView(mode: .items)
        bag += stackView.addArranged(itemsRow)
        
        return (stackView, bag)
    }
}
