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
    associatedtype Matter
    associatedtype Result

    func materialize(events: ViewableEvents) -> (Matter, Result)
}

struct ViewableEvents {
    let wasAdded: Signal<Void>
    let removeAfter = Delegate<Void, TimeInterval>()

    init(
        wasAddedCallbacker: Callbacker<Void>
    ) {
        wasAdded = wasAddedCallbacker.signal()
    }
}
