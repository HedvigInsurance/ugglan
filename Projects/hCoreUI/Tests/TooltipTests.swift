import Flow
import Foundation
import SnapshotTesting
import Testing
import UIKit
import XCTest
import hCore

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

    view.snp.makeConstraints { make in make.width.equalTo(2)
      make.height.equalTo(2)
      make.top.right.equalToSuperview()
    }

    assertSnapshot(matching: viewController, as: .image)
  }
}
