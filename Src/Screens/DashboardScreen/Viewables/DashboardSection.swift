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

struct DashboardSection {
    
}

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
        bag += stackView.addArangedSubview(referralSpacing)
        
        let row = MyProtectionView(mode: .coinsured)
        bag += stackView.addArangedSubview(row)
        
        return (stackView, bag)
    }
}
