import XCTest
import hCore

@testable import TerminateContracts

final class TerminateContractsTests: XCTestCase {
    weak var sut: MockTerminateContractsService?
    @Inject var terminationService: MockTerminateContractsService

    override func setUp() {
        super.setUp()
    }

    override func tearDownWithError() throws {
        XCTAssertNil(sut)
    }

    func testSendTerminationDateSuccess() async {
        // Create an implementation of the TerminateContractsClient and inject that one in the dependencies
        let terminationDate = "2024-08-31"

        Task {
            let mockService = try await terminationService.sendTerminationDate(
                inputDateToString: terminationDate,
                terminationContext: "context"
            )
        }

        // Create a new instance of the store
        let terminationStore = TerminationContractStore()

        // Send await event to the store to send termination date
        Task {
            try await terminationStore.terminateContractsService.sendTerminationDate(
                inputDateToString: terminationDate,
                terminationContext: "context"
            )
        }

        // Check if the state of the store is filled with proper data
        assert(terminationStore.state.terminationDateStep != nil)
        assert(terminationStore.state.terminationDateStep?.date == terminationDate.localDateToDate)

        self.sut = terminationService
    }
}
