import Apollo
import Flow
import Foundation
import Presentation
import SnapshotTesting
import SwiftUI
import TestDependencies
import Testing
import TestingUtil
import XCTest
import hCore
import hCoreUI
import hGraphQL

@testable import Home

class HomeTests: XCTestCase {
    let bag = DisposeBag()

    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }

    func perform(_ body: JSONObject, assertions: @escaping (_ view: UIView) -> Void) {

    }
}
