import MoveFlowCore
import Testing
import hCore

@testable import MoveFlowUI

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

        @Test
        func asMoveAddressInputCopiesFormValues() async {
            let model = AddressInputModel()
            model.address = "Testvägen 123"
            model.postalCode = "111 11"
            model.squareArea = "80"
            model.nbOfCoInsured = 2
            model.accessDate = "2025-09-08".localDateToDate
            model.isStudent = true
            model.selectedHousingType = .rental

            let input = model.asMoveAddressInput

            #expect(input.address == "Testvägen 123")
            #expect(input.postalCode == "111 11")
            #expect(input.squareArea == "80")
            #expect(input.nbOfCoInsured == 2)
            #expect(input.accessDate == "2025-09-08".localDateToDate)
            #expect(input.isStudent)
            #expect(input.selectedHousingType == .rental)
        }
    }
}
