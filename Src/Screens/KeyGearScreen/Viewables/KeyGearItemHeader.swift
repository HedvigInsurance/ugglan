//
//  KeyGearItemHeader.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-14.
//

import Foundation
import Flow
import UIKit
import Form

struct KeyGearItemHeader {}

extension KeyGearItemHeader: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        let valuationBox = SectionView()
        valuationBox.dynamicStyle = .sectionPlain
        
        valuationBox.appendRow(RowView().append(UILabel(value: "Fisk", style: .body)))
        
        stackView.addArrangedSubview(valuationBox)
        
        valuationBox.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        let deductibleBox = SectionView()
        deductibleBox.dynamicStyle = .sectionPlain
        
        deductibleBox.appendRow(RowView().append(UILabel(value: "Fisk", style: .body)))
        
        stackView.addArrangedSubview(deductibleBox)
        
        deductibleBox.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        return (stackView, NilDisposer())
    }
}
