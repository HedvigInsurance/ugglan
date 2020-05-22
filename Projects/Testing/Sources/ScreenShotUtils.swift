//
//  ScreenShotUtils.swift
//  Testing
//
//  Created by sam on 22.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import hCoreUI
import hCore
import Flow
import SnapshotTesting
import UIKit

public func setupScreenShotTests() {
    if ProcessInfo.processInfo.environment["SNAPSHOT_TEST_MODE"] == "RECORD" {
        record = true
    }
}

public func materializeViewable<View: Viewable>(
    _ viewable: View,
    onCreated: (_ view: View.Matter) -> Void
) where View.Events == ViewableEvents, View.Matter: UIView, View.Result == Disposable {
    let bag = DisposeBag()
    let (matter, result) = viewable.materialize(events: ViewableEvents(wasAddedCallbacker: Callbacker()))
    matter.layoutIfNeeded()
    bag += result
    onCreated(matter)
    bag.dispose()
}

public func materializeViewable<View: Viewable, SignalKind, SignalValue>(
    _ viewable: View,
    onCreated: (_ view: View.Matter) -> Void
) where View.Events == ViewableEvents, View.Matter: UIView, View.Result == CoreSignal<SignalKind, SignalValue> {
    let bag = DisposeBag()
    let (matter, result) = viewable.materialize(events: ViewableEvents(wasAddedCallbacker: Callbacker()))
    matter.layoutIfNeeded()
    onCreated(matter)
    let _ = result.hold(bag)
}
