//
//  Divider.swift
//  Hedvig
//
//  Created by Axel Backlund on 2019-04-05.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit
import Core

struct Divider {
    let backgroundColor: UIColor
}

extension Divider: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let divider = UIView()

        let bag = DisposeBag()

        divider.backgroundColor = backgroundColor

        divider.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.height.equalTo(1)
        }

        return (divider, bag)
    }
}
