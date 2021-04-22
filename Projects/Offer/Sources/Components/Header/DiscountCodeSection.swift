//
//  DiscountCodeSection.swift
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

struct DiscountCodeSection {}

extension DiscountCodeSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let section = SectionView()
        section.dynamicStyle = DynamicSectionStyle.brandGroupedNoBackground.rowInsets(UIEdgeInsets(top: 0, left: 15, bottom: 20, right: 15))
        let bag = DisposeBag()
        
        let row = RowView()
        section.append(row)
        
        let button = Button(
            title: "Add discount code",
            type: .iconTransparent(
                textColor: .brand(.primaryText()),
                icon: .left(image: hCoreUIAssets.circularPlus.image, width: 20)
            )
        )
        bag += row.append(button.alignedTo(alignment: .center))
        
        return (section, bag)
    }
}
