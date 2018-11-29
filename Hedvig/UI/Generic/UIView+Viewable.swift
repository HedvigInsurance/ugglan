//
//  UIView+Viewable.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-29.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

extension UIView {
    func add(_ viewable: Viewable) -> Disposable {
        let (view, disposable) = viewable.materialize()
        addSubview(view)
        view.snp.makeConstraints { make in
            viewable.makeConstraints(make: make)
        }
        return disposable
    }
}
