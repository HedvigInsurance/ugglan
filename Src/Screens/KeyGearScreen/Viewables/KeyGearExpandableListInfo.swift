//
//  KeyGearExpandableListInfo.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-01-30.
//

import Foundation
import Flow
import Form
import UIKit
import Presentation

struct KeyGearExpandableListInfo {
    let headerView: UIView?
    let footerView: UIView?
    
    init(
        headerView: UIView? = nil,
        footerView: UIView? = nil
    )
    {
        self.headerView = headerView
        self.footerView = footerView
    }
}

extension KeyGearExpandableListInfo: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let containerView = UIView()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        
        containerView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        let sectionView = SectionView(
            headerView: headerView,
            footerView: footerView)
        
        sectionView.dynamicStyle = .sectionPlain
        
        stackView.addArrangedSubview(sectionView)
        
        let afterSixMonths = KeyValueRow()
        afterSixMonths.keySignal.value = "Efter 6 månader"
        afterSixMonths.valueSignal.value = "Fullvärde"
        
        bag += sectionView.append(afterSixMonths)
        
        let afterOneYear = KeyValueRow()
        afterOneYear.keySignal.value = "Efter 1 år"
        afterOneYear.valueSignal.value = "-30 %"
        
        bag += sectionView.append(afterOneYear)
        
        let placeholder = KeyValueRow()
        placeholder.keySignal.value = "placeholder"
        placeholder.valueSignal.value = "placeholder"
        
        bag += sectionView.append(placeholder)
        
        let placeholder2 = KeyValueRow()
        placeholder2.keySignal.value = "placeholder"
        placeholder2.valueSignal.value = "placeholder"
        
        bag += sectionView.append(placeholder2)
        
        return (containerView, bag)
    }
}
