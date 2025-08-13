import Flow
import Form
import Foundation
import SnapshotTesting
import TestDependencies
import Testing
import XCTest
import hCoreUI

@testable import hCoreUI

final class DefaultStylingTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
        DefaultStyling.installCustom()
    }

    func testBase() {
        let bag = DisposeBag()
        let navigationController = hNavigationController()
        navigationController.navigationBar.prefersLargeTitles = true

        let viewController = UIViewController()
        bag += navigationController.present(
            viewController,
            options: [.defaults, .largeTitleDisplayMode(.always)]
        )

        viewController.title = "hCore UI"

        let form = FormView()
        bag += viewController.install(form)

        let section = form.appendSection(header: "Section header", footer: "Section footer")

        section.appendRow(title: "Test row", subtitle: "with a subtitle")
        section.appendRow(title: "Test row")

        ciAssertSnapshot(matching: navigationController, as: .image(on: .iPhoneX))

        bag.dispose()
    }

    func testDarkMode() {
        let bag = DisposeBag()
        let navigationController = hNavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.overrideUserInterfaceStyle = .dark

        let viewController = UIViewController()

        bag += navigationController.present(
            viewController,
            options: [.defaults, .largeTitleDisplayMode(.always)]
        )

        viewController.title = "hCore UI"

        let form = FormView()
        bag += viewController.install(form)

        let section = form.appendSection(header: "Section header", footer: "Section footer")

        section.appendRow(title: "Test row", subtitle: "with a subtitle")
        section.appendRow(title: "Test row")

        ciAssertSnapshot(matching: navigationController, as: .image(on: .iPhoneX))

        bag.dispose()
    }

    func testDarkModeElevated() {
        let bag = DisposeBag()
        let navigationController = hNavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.overrideUserInterfaceStyle = .dark

        let viewController = UIViewController()
        navigationController.setOverrideTraitCollection(
            UITraitCollection(userInterfaceLevel: .elevated),
            forChild: viewController
        )

        bag += navigationController.present(
            viewController,
            options: [.defaults, .largeTitleDisplayMode(.always)]
        )

        viewController.title = "hCore UI"

        let form = FormView()
        bag += viewController.install(form)

        let section = form.appendSection(header: "Section header", footer: "Section footer")

        section.appendRow(title: "Test row", subtitle: "with a subtitle")
        section.appendRow(title: "Test row")

        ciAssertSnapshot(matching: navigationController, as: .image(on: .iPhoneX))

        bag.dispose()
    }
}
