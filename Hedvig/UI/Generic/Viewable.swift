//
//  Viewable.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-29.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import SnapKit
import UIKit

protocol Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable)
}

struct ViewableEvents {
    let wasAdded: Signal<Void>
    let removeAfter = Delegate<Void, TimeInterval>()
    let willRemove: Signal<Void>

    init(wasAddedCallbacker: Callbacker<Void>, willRemoveCallbacker: Callbacker<Void>) {
        wasAdded = wasAddedCallbacker.signal()
        willRemove = willRemoveCallbacker.signal()
    }
}
