//
//  ScreenShotTestCase.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-22.
//

import Apollo
import SnapshotTesting
import Flow
import UIKit
import XCTest
import Presentation
import Form

class SnapShotTestCase: XCTestCase {
    let bag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        
        FontLoader.loadFonts()
        DefaultStyling.installCustom()
        
        #if RECORD_MODE
        record = true
        #endif
    }
    
    override func tearDown() {
        bag.dispose()
    }
    
    func waitForQuery<Query: GraphQLQuery>(_ query: Query, onFetched: @escaping () -> Void) {
        let waitForQuery = expectation(description: "wait for query")
        
        bag += ApolloContainer.shared.client.fetch(query: query).onValue { _ in
            onFetched()
            waitForQuery.fulfill()
        }
        
        wait(for: [waitForQuery], timeout: 5)
    }
}
