//
//  InvitationRowTests.swift
//  ForeverTests
//
//  Created by sam on 8.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import hCoreUI
import SnapshotTesting
import Testing
import XCTest
@testable import Forever

final class InvitationRowTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
        DefaultStyling.installCustom()
    }
    
    func setupTableKit(holdIn bag: DisposeBag) -> TableKit<EmptySection, InvitationRow> {
        let tableKit = TableKit<EmptySection, InvitationRow>(holdIn: bag)
        bag += tableKit.delegate.heightForCell.set { _ -> CGFloat in
            InvitationRow.cellHeight
        }
        
        tableKit.view.snp.makeConstraints { make in
            make.height.equalTo(400)
            make.width.equalTo(300)
        }
        
        return tableKit
    }

    func testPendingState() {
        let invitationRow = InvitationRow(name: "mock", state: .pending, discount: .sek(10))
        
        let bag = DisposeBag()
        
        let tableKit = setupTableKit(holdIn: bag)
        
        tableKit.table = Table(rows: [invitationRow])
        
        assertSnapshot(matching: tableKit.view, as: .image)
        
        bag.dispose()
    }
    
    func testActiveState() {
        let invitationRow = InvitationRow(name: "mock", state: .active, discount: .sek(10))
        
        let bag = DisposeBag()
        
        let tableKit = setupTableKit(holdIn: bag)
        
        tableKit.table = Table(rows: [invitationRow])
        
        assertSnapshot(matching: tableKit.view, as: .image)
        
        bag.dispose()
    }
    
    func testTerminatedState() {
        let invitationRow = InvitationRow(name: "mock", state: .terminated, discount: .sek(10))
       
       let bag = DisposeBag()
       
       let tableKit = setupTableKit(holdIn: bag)
       
       tableKit.table = Table(rows: [invitationRow])
       
       assertSnapshot(matching: tableKit.view, as: .image)
       
       bag.dispose()
   }
}

