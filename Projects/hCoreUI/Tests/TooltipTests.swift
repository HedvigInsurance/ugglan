import Flow
import Foundation
import hCore
import SnapshotTesting
import SwiftUI
import TestDependencies
import Testing
import XCTest

@testable import hCoreUI

final class TooltipTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    func testScreenshot() {
        let tooltip = Tooltip(id: "mock", value: "mock", sourceRect: .zero)

        let viewController = UIViewController()

        let bag = DisposeBag()
        let view = UIView()
        viewController.view.addSubview(view)
        bag += view.present(tooltip)

        view.snp.makeConstraints { make in
            make.width.equalTo(2)
            make.height.equalTo(2)
            make.top.right.equalToSuperview()
        }

        ciAssertSnapshot(matching: viewController, as: .image)
    }
}
