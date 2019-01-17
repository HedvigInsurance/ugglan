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
}

extension Spacing: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()

        view.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.height.equalTo(self.height)
        }

        return (view, NilDisposer())
    }
}
