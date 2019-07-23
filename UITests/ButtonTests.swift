//
//  UITests.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-03-30.
//

import Apollo
import SnapshotTesting
import Flow
import UIKit
import XCTest

class ButtonTests: SnapShotTestCase {
    func testStandard() {
        let view = UIView()

        let button = Button(
            title: "Lorem ipsum",
            type: .standard(
                backgroundColor: .purple,
                textColor: .white
            )
        )
        bag += view.add(button) { buttonView in
            view.snp.makeConstraints { make in
                make.width.equalTo(buttonView.snp.width)
                make.height.equalTo(buttonView.snp.height)
            }
        }
        
        view.layoutIfNeeded()
        
        assertSnapshot(matching: view, as: .image)
    }

    func testLoadableButton() {
        let view = UIView()

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

        bag += view.add(loadableButton) { buttonView in
            view.snp.makeConstraints { make in
                make.height.equalTo(buttonView.snp.height)
                make.width.equalTo(buttonView.snp.width)
            }
        }
        
        view.layoutIfNeeded()

        assertSnapshot(matching: view, as: .image)
    }
}
