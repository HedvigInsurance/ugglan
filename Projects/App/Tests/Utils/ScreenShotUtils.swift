//
//  ScreenShotTestCase.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-22.
//

import Apollo
import Flow
import Form
import hCore
import Presentation
import SnapshotTesting
import Ugglan
import UIKit
import XCTest

func setupScreenShotTests() {
    DefaultStyling.installCustom()

    Dependencies.shared.add(module: Module { () -> AnalyticsCoordinator in
        AnalyticsCoordinator()
   })

    if ProcessInfo.processInfo.environment["SNAPSHOT_TEST_MODE"] == "RECORD" {
        record = true
    }
}

func materializeViewable<View: Viewable>(
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
