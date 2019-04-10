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

struct MyProtectionSection {
    let dataSignal: ReadWriteSignal<DashboardQuery.Data.Insurance?> = ReadWriteSignal(nil)
}

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
        stackView.isHidden = true
        bag += dataSignal.map { $0 == nil }.bindTo(stackView, \.isHidden)
        
        let title = UILabel(value: "Ditt skydd", style: .rowTitle)
        stackView.addArrangedSubview(title)
        
        let rowSpacing = Spacing(height: 10)
        bag += stackView.addArranged(rowSpacing)
        
        let perilCategoriesStack = UIStackView()
        perilCategoriesStack.axis = .vertical
        stackView.addArrangedSubview(perilCategoriesStack)
        
        bag += dataSignal.atOnce().compactMap { $0?.perilCategories }.onValue { perilCategories in
            perilCategoriesStack.subviews.forEach { view in
                view.removeFromSuperview()
            }
            
            for (index, perilCategory) in perilCategories.enumerated() {
                let protectionSection = PerilExpandableRow(index: index)
                protectionSection.perilsDataSignal.value = perilCategory
                bag += perilCategoriesStack.addArranged(protectionSection)
                bag += perilCategoriesStack.addArranged(rowSpacing)
            }
            
            let moreInfoSection = MoreInfoExpandableRow()
            bag += perilCategoriesStack.addArranged(moreInfoSection)
        }
        
        return (stackView, bag)
    }
}
