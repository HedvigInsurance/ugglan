import Foundation
import UIKit
import XCTest

@testable import hCoreUI

final class ColorTests: XCTestCase {
  func testHedvigColors() {
    let view = UIView()
    view.backgroundColor = .brand(.primaryTintColor)
  }

  func testDynamicPolyfill() {
    let color = UIColor { trait -> UIColor in trait.userInterfaceStyle == .dark ? .black : .white }

    XCTAssert(
      color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)).cgColor
        == UIColor.black.cgColor
    )
    XCTAssert(
      color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)).cgColor
        == UIColor.white.cgColor
    )
  }
}
