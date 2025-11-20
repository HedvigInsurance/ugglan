import SwiftUI

final class SubmitClaimFileUploadStep: ClaimIntentStepHandler {
    @Published var selectedOption: String?
    let model: ClaimIntentStepContentFileUpload
    let fileUploadVm: FilesUploadViewModel

    required init(
        claimIntent: ClaimIntent,
        service: ClaimIntentService,
        mainHandler: @escaping (SubmitClaimEvent) -> Void
    ) {
        guard case .fileUpload(let model) = claimIntent.currentStep.content else {
            fatalError("TextStepHandler initialized with non-single select content")
        }
        self.model = model
        fileUploadVm = .init(model: .init(uploadUri: model.uploadURI))
        super.init(claimIntent: claimIntent, service: service, mainHandler: mainHandler)
    }

    @discardableResult
    override func submitResponse() async throws {
        withAnimation {
            isLoading = true
        }
        defer {
            withAnimation {
                isLoading = false
            }
        }
        let uploadedFiles = await fileUploadVm.uploadFiles()

        let result = try await service.claimIntentSubmitFile(stepId: id, fildIds: uploadedFiles)

        guard let result else {
            throw ClaimIntentError.invalidResponse
        }
        switch result {
        case let .intent(model):
            mainHandler(.goToNext(claimIntent: model))
        case let .outcome(model):
            mainHandler(.outcome(model: model))
        }

        withAnimation {
            isEnabled = false
        }
    }
}
