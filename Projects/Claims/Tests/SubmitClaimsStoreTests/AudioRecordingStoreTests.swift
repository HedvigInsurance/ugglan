import PresentableStore
import XCTest

@testable import Claims

final class AudioRecordingStoreTests: XCTestCase {
    weak var store: SubmitClaimStore?

    let audioModel: FlowClaimAudioRecordingStepModel = .init(
        id: "id",
        questions: [],
        textQuestions: [],
        inputTextContent: nil,
        optionalAudio: true
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

    func testAudioRecordingSuccess() async {
        MockData.createMockSubmitClaimService(audioRecording: { type, fileUploaderClient, context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.2,
                action: .stepModelAction(action: .setSuccessStep(model: .init(id: "id")))
            )
        })

        MockData.createMockFileUploaderService(uploadFile: { _, _ in
            .init(audioUrl: "https://audioUrl")
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setAudioStep(model: audioModel))
        )

        if let url = URL(string: "https://audioUrl") {
            await store.sendAsync(.submitAudioRecording(type: .audio(url: url)))
        }

        assert(store.state.successStep != nil)
        assert(store.state.failedStep == nil)
        assert(store.state.audioRecordingStep == audioModel)
    }

    func testAudioRecordingResponseFailure() async {
        MockData.createMockSubmitClaimService(audioRecording: { type, fileUploaderClient, context in
            .init(
                claimId: "claim id",
                context: context,
                progress: 0.1,
                action: .stepModelAction(action: .setFailedStep(model: .init(id: "id")))
            )
        })

        MockData.createMockFileUploaderService(uploadFile: { _, _ in
            .init(audioUrl: "https://audioUrl")
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setAudioStep(model: audioModel))
        )

        if let url = URL(string: "https://audioUrl") {
            await store.sendAsync(.submitAudioRecording(type: .audio(url: url)))
        }

        await waitUntil(description: "loading state") {
            store.loadingState[.postAudioRecording] == nil
        }

        assert(store.state.successStep == nil)
        assert(store.state.failedStep != nil)
    }

    func testAudioRecordingThrowFailure() async {
        MockData.createMockSubmitClaimService(audioRecording: { _, _, _ in
            throw ClaimsError.error
        })

        MockData.createMockFileUploaderService(uploadFile: { _, _ in
            .init(audioUrl: "https://audioUrl")
        })

        let store = SubmitClaimStore()
        self.store = store
        await store.sendAsync(
            .stepModelAction(action: .setAudioStep(model: audioModel))
        )

        if let url = URL(string: "https://audioUrl") {
            await store.sendAsync(.submitAudioRecording(type: .audio(url: url)))
        }

        await waitUntil(description: "loading state") {
            if case .error = store.loadingState[.postAudioRecording] { return true } else { return false }
        }
        assert(store.state.successStep == nil)
        assert(store.state.failedStep == nil)
    }
}
