import PresentableStore
import XCTest

@testable import Claims

final class EmergencyConfirmRequestStoreTests: XCTestCase {
    weak var store: SubmitClaimStore?

    let emergencyConfirmModel: FlowClaimConfirmEmergencyStepModel = .init(
        id: "id",
        text: "text",
        confirmEmergency: true,
        options: [
            .init(displayName: "option1", value: true),
            .init(displayName: "option2", value: false),
        ]
    )

    override func setUp() {
        super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
    }

    func testEmergencyConfirmRequestSuccess() async {
        MockData.createMockSubmitClaimService(emergencyConfirm: { isEmeregency, context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.1,
                action: .stepModelAction(action: .setSuccessStep(model: .init(id: "id")))
            )
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setConfirmDeflectEmergencyStepModel(model: emergencyConfirmModel))
        )

        await store.sendAsync(.emergencyConfirmRequest(isEmergency: false))

        assert(store.state.successStep != nil)
        assert(store.state.failedStep == nil)
        assert(store.state.emergencyConfirm == emergencyConfirmModel)
    }

    func testEmergencyConfirmRequestResponseFailure() async {
        MockData.createMockSubmitClaimService(emergencyConfirm: { isEmeregency, context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.1,
                action: .stepModelAction(action: .setFailedStep(model: .init(id: "id")))
            )
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setConfirmDeflectEmergencyStepModel(model: emergencyConfirmModel))
        )

        await store.sendAsync(.emergencyConfirmRequest(isEmergency: false))

        await waitUntil(description: "loading state") {
            store.loadingState[.postConfirmEmergency] == nil
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep != nil)
    }

    func testEmergencyConfirmRequestThrowFailure() async {
        MockData.createMockSubmitClaimService(emergencyConfirm: { isEmeregency, context in
            throw ClaimsError.error
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setConfirmDeflectEmergencyStepModel(model: emergencyConfirmModel))
        )

        await store.sendAsync(.emergencyConfirmRequest(isEmergency: false))

        await waitUntil(description: "loading state") {
            if case .error = store.loadingState[.postConfirmEmergency] { return true } else { return false }
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep == nil)
    }
}
