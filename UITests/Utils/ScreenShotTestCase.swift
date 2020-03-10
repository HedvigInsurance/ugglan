//
//  ScreenShotTestCase.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-22.
//

import Apollo
import Flow
import Form
import Presentation
import SnapshotTesting
import UIKit
import XCTest
import ComponentKit

class SnapShotTestCase: XCTestCase {
    let bag = DisposeBag()

    override func setUp() {
        super.setUp()

        FontLoader.loadFonts()

        #if RECORD_MODE
            record = true
        #endif
    }

    override func tearDown() {
        bag.dispose()
    }

    func materializeViewable<View: Viewable>(
        _ viewable: View,
        onCreated: (_ view: View.Matter) -> Void
    ) where View.Events == ViewableEvents, View.Matter: UIView, View.Result == Disposable {
        let (matter, result) = viewable.materialize(events: ViewableEvents(wasAddedCallbacker: Callbacker()))
        matter.layoutIfNeeded()
        bag += result
        onCreated(matter)
    }
}
