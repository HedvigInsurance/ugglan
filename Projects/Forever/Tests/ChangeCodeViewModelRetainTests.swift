import XCTest
import hCore
import hCoreUI

@testable import Forever

@MainActor
final class ChangeCodeViewModelRetainTests: XCTestCase {
    weak var sut: MockForeverService?

    override func setUp() async throws {
        try await super.setUp()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: ForeverClient.self)
        await delay(0.0000001)

        XCTAssertNil(sut)
    }

    func testInputViewModelCallbacksDoNotRetainOwner() {
        let mockService = MockData.createMockForeverService()
        sut = mockService

        var owner: ChangeCodeViewModel? = ChangeCodeViewModel(input: "code", foreverVm: ForeverNavigationViewModel())
        weak let weakOwner = owner

        // TextInputView's save button keeps the TextInputViewModel alive for the whole in-flight
        // request, so this local reproduces that lifetime: it outlives the owner on purpose, and a
        // strong capture in either callback would be visible as a surviving owner below.
        let inputVm: TextInputViewModel = owner!.inputVm

        XCTAssertNotNil(inputVm.onSave, "onSave must be installed by init")
        XCTAssertNotNil(inputVm.onDismiss, "onDismiss must be installed by init")

        owner = nil

        XCTAssertNil(weakOwner, "closures stored on inputVm must not keep ChangeCodeViewModel alive")
        withExtendedLifetime(inputVm) {}
    }
}
