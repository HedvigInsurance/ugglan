import Presentation
import XCTest
import hCore

@testable import MoveFlow

final class AddressInputModelTests: XCTestCase {
    weak var store: MoveFlowStore?

    override func setUp() {
        super.setUp()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
    }

    func testIsStudentEnabledFalseInputValidSuccess() async {
        let store = MoveFlowStore()
        self.store = store

        let model = AddressInputModel()

        model.postalCode = "11111"
        model.squareArea = "80"
        model.address = "Testvägen 123"
        model.accessDate = "2025-09-08".localDateToDate

        await model.store.sendAsync(.setHousingType(with: .apartment))

        assert(model.isStudentEnabled == false)
        assert(model.isInputValid() == true)
    }

    func testIsStudentEnabledFalseInputNotValidSuccess() async {
        let store = MoveFlowStore()
        self.store = store

        let model = AddressInputModel()

        await model.store.sendAsync(.setHousingType(with: .house))

        assert(model.isStudentEnabled == false)
        assert(model.isInputValid() == false)
    }
}
