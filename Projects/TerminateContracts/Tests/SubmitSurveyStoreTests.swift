import PresentableStore
import XCTest

@testable import TerminateContracts

final class SubmitSurveyStoreTests: XCTestCase {
    weak var store: TerminationContractStore?

    let terminationSurveyStep: TerminationFlowSurveyStepModel = .init(
        id: "is",
        options: [
            .init(
                id: "id",
                title: "title",
                suggestion: nil,
                feedBack: nil,
                subOptions: nil
            )
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

    func testSubmitSurveySuccess() async {
        MockData.createMockTerminateContractsService(
            surveySend: { context, option, inputData in
                .init(
                    context: context,
                    action: .stepModelAction(action: .setSuccessStep(model: .init(terminationDate: nil)))
                )
            }
        )

        let store = TerminationContractStore()
        self.store = store

        await store.sendAsync(.stepModelAction(action: .setTerminationSurveyStep(model: terminationSurveyStep)))
        await store.sendAsync(.submitSurvey(option: "option", feedback: "feedback"))

        assert(store.state.successStep != nil)
        assert(store.state.failedStep == nil)
        assert(store.state.terminationSurveyStep == terminationSurveyStep)
    }

    func testSubmitSurveyResponseFailure() async {
        MockData.createMockTerminateContractsService(
            surveySend: { context, option, inputData in
                .init(context: context, action: .stepModelAction(action: .setFailedStep(model: .init(id: "id"))))
            }
        )

        let store = TerminationContractStore()
        self.store = store

        await store.sendAsync(.stepModelAction(action: .setTerminationSurveyStep(model: terminationSurveyStep)))
        await store.sendAsync(.submitSurvey(option: "option", feedback: "feedback"))
        await waitUntil(description: "loading state") {
            store.loadingSignal.value[.sendSurvey] == nil
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep != nil)
    }

    func testSubmitSurveyThrowFailure() async {
        MockData.createMockTerminateContractsService(
            surveySend: { context, option, inputData in
                throw TerminationError.error
            }
        )

        let store = TerminationContractStore()
        self.store = store

        await store.sendAsync(.stepModelAction(action: .setTerminationSurveyStep(model: terminationSurveyStep)))
        await store.sendAsync(.submitSurvey(option: "option", feedback: "feedback"))

        await waitUntil(description: "loading state") {
            store.loadingSignal.value[.sendSurvey] != nil
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep == nil)
    }
}
