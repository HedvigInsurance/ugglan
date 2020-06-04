//
//  Header.swift
//  Forever
//
//  Created by sam on 4.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Flow
import hCore
import hCoreUI

struct Header {}

extension Header: Viewable {
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let stackView = UIStackView()
        let bag = DisposeBag()
        
        bag += stackView.addArranged(PieChart(slicesSignal: .init([.init(percent: 0.1, color: .brand(.primaryButtonBackgroundColor)), .init(percent: 0.1, color: .brown)])))
        
        return (stackView, bag)
    }
}
