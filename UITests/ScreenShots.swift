//
//  ScreenShots.swift
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

class ScreenShots: SnapShotTestCase {
    func testDashboard() {
        let bag = DisposeBag()
        
        let dashboard = Dashboard(
            remoteConfig: RemoteConfigContainer()
        )
        
        let tabBarController = UITabBarController()
        
        let dashboardPresentation = Presentation(
            dashboard,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )
        
        bag += tabBarController.presentTabs(dashboardPresentation)
        
        let waitForData = expectation(description: "wait for data")
        
        bag += ApolloContainer.shared.client.watch(query: DashboardQuery()).onValue { _ in
            assertSnapshot(matching: tabBarController, as: .image(on: .iPhoneSe))
            assertSnapshot(matching: tabBarController, as: .image(on: .iPhoneX))
            assertSnapshot(matching: tabBarController, as: .image(on: .iPhone8))
            assertSnapshot(matching: tabBarController, as: .image(on: .iPadPro10_5))
            
            bag.dispose()
            
            waitForData.fulfill()
        }
        
        wait(for: [waitForData], timeout: 5)
    }
}
