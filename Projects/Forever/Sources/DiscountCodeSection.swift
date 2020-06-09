//
//  DiscountCodeSection.swift
//  Forever
//
//  Created by sam on 8.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import hCore
import UIKit
import hCoreUI
import Form
import Flow

struct DiscountCodeSection {}

extension DiscountCodeSection: Viewable {
    func materialize(events: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView(
            headerView: UILabel(value: L10n.ReferralsEmpty.Code.headline, style: .default),
            footerView: {
                let stackView = UIStackView()
                
                let label = MultilineLabel(value: L10n.ReferralsEmpty.Code.footer, style: TextStyle.brand(.footnote(color: .tertiary)))
                
                bag += stackView.addArranged(label)
                
                return stackView
        }()
        )
        
        let codeRow = RowView()
        let codeLabel = UILabel(value: "HJQ081", style: TextStyle.brand(.body(color: .primary)).centerAligned)
        codeRow.append(codeLabel)
        
        bag += section.append(codeRow).onValue { _ in
            bag += section.viewController?.displayToast(title: "Copied!")
        }
                
        return (section, bag)
    }
}
