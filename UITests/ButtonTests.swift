//
//  UITests.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-03-30.
//

import Apollo
import Flow
import SnapshotTesting
import UIKit
import XCTest

class ButtonTests: SnapShotTestCase {
    func testStandard() {
        let button = Button(
            title: "Lorem ipsum",
            type: .standard(
                backgroundColor: .purple,
                textColor: .white
            )
        )

        materializeViewable(button) { view in
            assertSnapshot(matching: view, as: .image)
        }
    }

    func testLoadableButton() {
        let button = Button(
            title: "testa",
            type: .standard(
                backgroundColor: .purple,
                textColor: .white
            )
        )

        let loadableButton = LoadableButton(
            button: button,
            initialLoadingState: true
        )

        materializeViewable(loadableButton) { view in
            assertSnapshot(matching: view, as: .image)
        }
    }
}
