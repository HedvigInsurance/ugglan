//
//  Form+Append.swift
//  hCore
//
//  Created by Sam Pettersson on 2022-03-07.
//  Copyright © 2022 Hedvig AB. All rights reserved.
//

import Foundation
import Form
import UIKit
import Flow

extension SubviewOrderable {
    /// appends view and removes from superview on disposal
    public func appendRemovable<V: UIView>(_ view: V) -> Disposable {
        orderedViews.append(view)
        return Disposer {
            view.removeFromSuperview()
        }
    }
}
