//
//  PieChartTests.swift
//  ForeverTests
//
//  Created by sam on 5.6.20.
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

final class PieChartTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
        DefaultStyling.installCustom()
    }

    func test() {
        let pieChart = PieChart(stateSignal: .init(.init(percentagePerSlice: 0.25, slices: 2)), animated: false)
        
        materializeViewable(pieChart) { view in
            view.snp.makeConstraints { make in
                make.width.height.equalTo(215)
            }
                        
            assertSnapshot(matching: view, as: .image)
            
            pieChart.stateSignal.value = .init(percentagePerSlice: 0.05, slices: 10)
            assertSnapshot(matching: view, as: .image)
            
            pieChart.stateSignal.value = .init(percentagePerSlice: 0.05, slices: 5)
            assertSnapshot(matching: view, as: .image)
            
            pieChart.stateSignal.value = .init(percentagePerSlice: 0.05, slices: 12)
            assertSnapshot(matching: view, as: .image)
            
            pieChart.stateSignal.value = .init(percentagePerSlice: 0.5, slices: 2)
            assertSnapshot(matching: view, as: .image)
            
            pieChart.stateSignal.value = .init(percentagePerSlice: 0.5, slices: 1.5)
            assertSnapshot(matching: view, as: .image)
            
            pieChart.stateSignal.value = .init(percentagePerSlice: 0.05, slices: 1.5)
            assertSnapshot(matching: view, as: .image)
            
            pieChart.stateSignal.value = .init(grossAmount: 100, netAmount: 50, potentialDiscountAmount: 10)
            assertSnapshot(matching: view, as: .image)
            
            pieChart.stateSignal.value = .init(grossAmount: 1000, netAmount: 5, potentialDiscountAmount: 10)
            assertSnapshot(matching: view, as: .image)
        }
    }
    
    func testMoneyToPieChartState() {
        let state = PieChartState(grossAmount: 1000, netAmount: 5, potentialDiscountAmount: 10)
        XCTAssert(state.percentagePerSlice == 0.01)
        XCTAssert(state.slices == 99.5)
        
        let state2 = PieChartState(grossAmount: 100, netAmount: 90, potentialDiscountAmount: 10)
        XCTAssert(state2.percentagePerSlice == 0.1)
        XCTAssert(state2.slices == 1)
    }
}
