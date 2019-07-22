//
//  ScreenShots.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-22.
//

import Apollo
import FBSnapshotTestCase
import Flow
import UIKit
import XCTest
import Presentation
import Form

class ScreenShots: ScreenShotTestCase {
    func testDashboard() {
        let bag = DisposeBag()
        
        let dashboard = Dashboard(
            remoteConfig: RemoteConfigContainer()
        )
        
        let waitForRender = expectation(description: "wait for render")
        
        let windows = self.screenShotWindows.map { (arg) -> (UIWindow, String) in
            let (window, identifier) = arg
            let tabBarController = UITabBarController()
            
            let dashboardPresentation = Presentation(
                dashboard,
                style: .default,
                options: [.defaults, .prefersLargeTitles(true)]
            )
            
            bag += tabBarController.presentTabs(dashboardPresentation)
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
            
            return (window, identifier)
        }
        
        bag += Signal(after: 2).onValue { _ in
            windows.forEach { window, identifier in
                self.FBSnapshotVerifyView(window, identifier: identifier)
            }
            
            waitForRender.fulfill()
            bag.dispose()
        }
        
        wait(for: [waitForRender], timeout: 5)
    }
}
