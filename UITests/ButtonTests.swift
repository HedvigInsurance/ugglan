//
//  UITests.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-03-30.
//

import SnapshotTesting
import UIKit
import XCTest
import ComponentKit

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

    func testStandardWithDifferentText() {
        let button = Button(
            title: "Mauris velit consectetur interdum eget habitasse velit nisi, tempor venenatis scelerisque donec",
            type: .standard(
                backgroundColor: .purple,
                textColor: .white
            )
        )

        materializeViewable(button) { view in
            assertSnapshot(matching: view, as: .image)
        }
    }

    func testStandardWithDifferentColors() {
        let button = Button(
            title: "Lorem ipsum",
            type: .standard(
                backgroundColor: .blue,
                textColor: .black
            )
        )

        materializeViewable(button) { view in
            assertSnapshot(matching: view, as: .image)
        }
    }

    func testpillSemiTransparent() {
        let button = Button(
            title: "Lorem ipsum",
            type: .pillSemiTransparent(backgroundColor: .black, textColor: .white)
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
