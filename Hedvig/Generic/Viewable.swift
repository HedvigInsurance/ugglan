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
    associatedtype Events

    func materialize(events: Events) -> (Matter, Result)
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

struct SelectableViewableEvents {
    let wasAdded: Signal<Void>
    let removeAfter = Delegate<Void, TimeInterval>()
    let onSelect: Signal<Void>

    init(
        wasAddedCallbacker: Callbacker<Void>,
        onSelectCallbacker: Callbacker<Void>
    ) {
        wasAdded = wasAddedCallbacker.signal()
        onSelect = onSelectCallbacker.signal()
    }
}
