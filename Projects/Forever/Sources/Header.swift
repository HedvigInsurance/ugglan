//
//  Header.swift
//  Forever
//
//  Created by sam on 4.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import hCore
import hCoreUI
import UIKit

struct Header {}

extension Header: Viewable {
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let stackView = UIStackView()
        let bag = DisposeBag()

        bag += stackView.addArranged(PieChart(stateSignal: .init(.init(percentagePerSlice: 0.1, slices: 2))))

        return (stackView, bag)
    }
}
