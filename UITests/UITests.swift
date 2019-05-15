//
//  UITests.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-03-30.
//

import Apollo
import FBSnapshotTestCase
import Flow
import UIKit
import XCTest

class UITests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        
        #if RECORD_MODE
            recordMode = true
        #endif
        
        FontLoader.loadFonts(fontNames: ["Merriweather-Light", "CircularStd-Bold", "CircularStd-Book", "SoRay-ExtraBold"])
    }
    

    func testExample() {
        let bag = DisposeBag()
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

        FBSnapshotVerifyView(view)

        bag.dispose()
    }

    func testLoadableButton() {
        let bag = DisposeBag()
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

        FBSnapshotVerifyView(view)

        bag.dispose()
    }
}
