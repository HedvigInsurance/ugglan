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

public protocol Viewable {
    associatedtype Matter
    associatedtype Result
    associatedtype Events

    func materialize(events: Events) -> (Matter, Result)
}

public struct ViewableEvents {
    public let wasAdded: Signal<Void>
    public let removeAfter = Delegate<Void, TimeInterval>()

    public init(
        wasAddedCallbacker: Callbacker<Void>
    ) {
        wasAdded = wasAddedCallbacker.providedSignal
    }
}

public struct SelectableViewableEvents {
    let wasAdded: Signal<Void>
    let removeAfter = Delegate<Void, TimeInterval>()
    private let onSelectCallbacker: Callbacker<Void>

    public var onSelect: Signal<Void> {
        return onSelectCallbacker.providedSignal
    }

    init(
        wasAddedCallbacker: Callbacker<Void>,
        onSelectCallbacker: Callbacker<Void>
    ) {
        wasAdded = wasAddedCallbacker.providedSignal
        self.onSelectCallbacker = onSelectCallbacker
    }
}
