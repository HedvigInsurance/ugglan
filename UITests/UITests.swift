//
//  UITests.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-03-30.
//

import XCTest
import FBSnapshotTestCase
import Flow
import Apollo

class UITests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func testExample() {
        let bag = DisposeBag()
        let view = UIView()
        
        let button = Button(
            title: "testa",
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
            }
        }
        
        FBSnapshotVerifyView(view)
        
        bag.dispose()
    }
}
