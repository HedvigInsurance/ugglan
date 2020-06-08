//
//  EmptyStateHeader.swift
//  Forever
//
//  Created by sam on 8.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Flow
import Form
import hCore
import hCoreUI

struct EmptyStateHeader {
    let isHiddenSignal = ReadWriteSignal<Bool>(true)
}

extension EmptyStateHeader: Viewable {
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true

        bag += isHiddenSignal.bindTo(stackView, \.isHidden)
        
        let title = MultilineLabel(value: L10n.ReferralsEmpty.headline, style: TextStyle.brand(.title1(color: .primary)).centerAligned)
        bag += stackView.addArranged(title)
        
        let body = MultilineLabel(value: L10n.ReferralsEmpty.body, style: TextStyle.brand(.body(color: .secondary)).centerAligned)
        bag += stackView.addArranged(body)
        
        return (stackView, bag)
    }
}
