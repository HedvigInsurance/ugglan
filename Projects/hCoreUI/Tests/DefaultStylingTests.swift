//
//  DefaultStylingTests.swift
//  hCoreUITests
//
//  Created by sam on 3.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
@testable import hCoreUI
import SnapshotTesting
import Testing
import XCTest

final class DefaultStylingTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
        DefaultStyling.installCustom()
    }

    func testBase() {
        let bag = DisposeBag()
        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true

        let viewController = UIViewController()
        bag += navigationController.present(viewController, options: [.defaults, .largeTitleDisplayMode(.always)])

        viewController.title = "hCore UI"

        let form = FormView()
        bag += viewController.install(form)

        let section = form.appendSection(header: "Section header", footer: "Section footer")

        section.appendRow(title: "Test row", subtitle: "with a subtitle")
        section.appendRow(title: "Test row")

        assertSnapshot(matching: navigationController, as: .image(on: .iPhoneX))

        bag.dispose()
    }

    func testDarkMode() {
        let bag = DisposeBag()
        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.overrideUserInterfaceStyle = .dark

        let viewController = UIViewController()

        bag += navigationController.present(viewController, options: [.defaults, .largeTitleDisplayMode(.always)])

        viewController.title = "hCore UI"

        let form = FormView()
        bag += viewController.install(form)

        let section = form.appendSection(header: "Section header", footer: "Section footer")

        section.appendRow(title: "Test row", subtitle: "with a subtitle")
        section.appendRow(title: "Test row")

        assertSnapshot(matching: navigationController, as: .image(on: .iPhoneX))

        bag.dispose()
    }

    func testDarkModeElevated() {
        let bag = DisposeBag()
        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.overrideUserInterfaceStyle = .dark

        let viewController = UIViewController()
        navigationController.setOverrideTraitCollection(UITraitCollection(userInterfaceLevel: .elevated), forChild: viewController)

        bag += navigationController.present(viewController, options: [.defaults, .largeTitleDisplayMode(.always)])

        viewController.title = "hCore UI"

        let form = FormView()
        bag += viewController.install(form)

        let section = form.appendSection(header: "Section header", footer: "Section footer")

        section.appendRow(title: "Test row", subtitle: "with a subtitle")
        section.appendRow(title: "Test row")

        assertSnapshot(matching: navigationController, as: .image(on: .iPhoneX))

        bag.dispose()
    }
}
