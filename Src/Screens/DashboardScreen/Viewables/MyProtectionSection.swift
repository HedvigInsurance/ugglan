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

struct MyProtectionSection {}

extension MyProtectionSection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.edgeInsets = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let title = UILabel(value: "Ditt skydd", style: .rowTitle)
        stackView.addArrangedSubview(title)
        
        let referralSpacing = Spacing(height: 10)
        let rowSpacing = Spacing(height: 10)
        
        bag += stackView.addArranged(referralSpacing)
        
        let coinsuredProtectionView = CoinsuredProtectionView()
        bag += stackView.addArranged(coinsuredProtectionView)
        
        bag += stackView.addArranged(rowSpacing)
        
        let homeProtectionView = HomeProtectionView()
        bag += stackView.addArranged(homeProtectionView)
        
        bag += stackView.addArranged(rowSpacing)
        
        let itemsProtectionView = ItemsProtectionView()
        bag += stackView.addArranged(itemsProtectionView)
        
        return (stackView, bag)
    }
}
