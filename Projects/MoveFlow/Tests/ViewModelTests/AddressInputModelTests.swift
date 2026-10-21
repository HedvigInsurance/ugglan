import Testing
import hCore

@testable import MoveFlow

extension MoveFlowDependencySuite {
    @MainActor
    final class AddressInputModelTests {
        init() {
            Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        }

        @Test
        func isStudentEnabledFalseInputValidSuccess() async {
            let model = AddressInputModel()

            model.postalCode = "11111"
            model.squareArea = "80"
            model.address = "Testvägen 123"
            model.accessDate = "2025-09-08".localDateToDate
            model.selectedHousingType = .apartment

            #expect(model.isStudent == false)
        }

        @Test
        func isStudentEnabledFalseInputNotValidSuccess() async {
            let model = AddressInputModel()
            model.selectedHousingType = .house

            #expect(model.isStudent == false)
        }
    }
}
