//
//  Spacing.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-16.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import UIKit

struct Spacing {
    let height: Float
    let isHiddenSignal = ReadWriteSignal<Bool>(false)
}

extension Spacing: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let view = UIView()
        
        view.snp.makeConstraints { make in
            make.height.equalTo(self.height).priority(.required)
        }
                
        view.layoutIfNeeded()

        bag += isHiddenSignal.bindTo(view, \.isHidden)

        return (view, bag)
    }
}
