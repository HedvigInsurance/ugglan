import XCTest
import hCore

@testable import TerminateContracts

final class TerminateContractsTests: XCTestCase {
    weak var sut: MockTerminateContractsService?
    weak var store: TerminationContractStore?
    override func setUp() {
        super.setUp()
    }

    override func tearDownWithError() throws {

    }

    func testStartTerminationSuccessWithTerminationDate() async {
        let context = "context"
        let terminationDate = "2024-08-31"
        let sut = MockTerminateContractsService.createMockService(
            startTermination: { _ in
                return .init(
                    context: context,
                    action: .stepModelAction(
                        action: .setTerminationDateStep(
                            model: .init(
                                id: "id",
                                maxDate: "2024-11-10",
                                minDate: "2024-07-10",
                                date: terminationDate.localDateToDate
                            )
                        )
                    )
                )
            }
        )
        Dependencies.shared.add(module: Module { () -> TerminateContractsClient in sut })
        let store = TerminationContractStore()
        self.sut = sut
        self.store = store
        await store.sendAsync(
            .startTermination(
                config: .init(contractId: "", contractDisplayName: "", contractExposureName: "", activeFrom: nil)
            )
        )
        // Check if the state of the store is filled with proper data
        assert(store.state.terminationDateStep != nil)
        assert(store.state.terminationDateStep?.date == terminationDate.localDateToDate)

    }
}
