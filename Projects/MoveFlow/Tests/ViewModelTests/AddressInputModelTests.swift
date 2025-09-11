@preconcurrency import XCTest
import hCore

@testable import MoveFlow

@MainActor
final class AddressInputModelTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    }

    override func tearDown() async throws {}

    func testIsStudentEnabledFalseInputValidSuccess() async {
        let model = AddressInputModel()

        model.postalCode = "11111"
        model.squareArea = "80"
        model.address = "Testvägen 123"
        model.accessDate = "2025-09-08".localDateToDate
        model.selectedHousingType = .apartment

        assert(model.isStudent == false)
    }

    func testIsStudentEnabledFalseInputNotValidSuccess() async {
        let model = AddressInputModel()
        model.selectedHousingType = .house

        assert(model.isStudent == false)
    }
}
