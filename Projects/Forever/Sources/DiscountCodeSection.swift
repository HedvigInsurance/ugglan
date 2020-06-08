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
                let label = UILabel(value: L10n.ReferralsEmpty.Code.footer, style: TextStyle.default.restyled({ (style: inout TextStyle) in
                    style.numberOfLines = 0
                    style.lineBreakMode = .byWordWrapping
                }))
                return label
        }()
        )
        
        let codeRow = RowView()
        let codeLabel = UILabel(value: "HJQ081", style: TextStyle.brand(.body(color: .primary)).centerAligned)
        codeRow.append(codeLabel)
        
        bag += section.append(codeRow).onValue { _ in
            print("hello")
        }
                
        return (section, bag)
    }
}
