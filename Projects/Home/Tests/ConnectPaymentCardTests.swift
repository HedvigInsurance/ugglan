import Apollo
import Flow
import Foundation
import HomeTesting
import SnapshotTesting
import TestDependencies
import Testing
import TestingUtil
import XCTest
import hCore
import hCoreUI
import hGraphQL

@testable import Home

final class ConnectPaymentCardTests: XCTestCase {
    let bag = DisposeBag()

    override func setUp() {
        super.setUp()
        setupScreenShotTests()
    }
}
