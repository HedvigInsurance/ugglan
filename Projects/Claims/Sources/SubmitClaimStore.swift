import Apollo
import Combine
import PresentableStore
import SwiftUI
import hCore

public final class SubmitClaimStore: LoadingStateStore<SubmitClaimsState, SubmitClaimsAction, ClaimsLoadingType> {
    @Inject var fileUploaderClient: FileUploaderClient
    @Inject var fetchEntrypointsClient: hFetchEntrypointsClient
    @Inject var submitClaimClient: SubmitClaimClient
    var progressCancellable: AnyCancellable?
    public override func effects(
        _ getState: @escaping () -> SubmitClaimsState,
        _ action: SubmitClaimsAction
    ) async {
        switch action {
        case .submitClaimOpenFreeTextChat:
            NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
        //        case let .startClaimRequest(entrypointId, entrypointOptionId):
        //            await executeAsync(loadingType: .startClaim) {
        //                try await self.submitClaimClient.startClaim(
        //                    entrypointId: entrypointId,
        //                    entrypointOptionId: entrypointOptionId
        //                )
        //            }
        case let .phoneNumberRequest(phoneNumberInput):
            break
        //            await executeAsync(loadingType: .postPhoneNumber) {
        //                try await self.submitClaimClient.updateContact(phoneNumber: phoneNumberInput, context: newClaimContext)
        //            }
        //        case .dateOfOccurrenceAndLocationRequest:
        //            await executeAsync(loadingType: .postDateOfOccurrenceAndLocation) {
        //                try await self.submitClaimClient.dateOfOccurrenceAndLocationRequest(context: newClaimContext)
        //            }
        case let .submitAudioRecording(type):
            break
        //            await executeAsync(loadingType: .postAudioRecording) {
        //                try await self.submitClaimClient.submitAudioRecording(
        //                    type: type,
        //                    fileUploaderClient: self.fileUploaderClient,
        //                    context: newClaimContext
        //                )
        //            }
        case .summaryRequest:
            break
        //            await executeAsync(loadingType: .postSummary) {
        //                try await self.submitClaimClient.summaryRequest(context: newClaimContext)
        //            }
        case .singleItemCheckoutRequest:
            break
        //            await executeAsync(loadingType: .postSingleItemCheckout) {
        //                try await self.submitClaimClient.singleItemCheckoutRequest(context: newClaimContext)
        //            }

        case let .contractSelectRequest(contractId):
            break
        //            await executeAsync(loadingType: .postContractSelect) {
        //                try await self.submitClaimClient.contractSelectRequest(
        //                    contractId: contractId ?? "",
        //                    context: newClaimContext
        //                )
        //            }
        case let .emergencyConfirmRequest(isEmergency):
            break
        //            await executeAsync(loadingType: .postConfirmEmergency) {
        //                try await self.submitClaimClient.emergencyConfirmRequest(
        //                    isEmergency: isEmergency,
        //                    context: newClaimContext
        //                )
        //            }
        case let .submitFileUpload(ids):
            break
        //            await executeAsync(loadingType: .postUploadFiles) {
        //                try await self.submitClaimClient.submitFileUpload(ids: ids, context: newClaimContext)
        //            }
        default:
            break
        }
    }

    public override func reduce(_ state: SubmitClaimsState, _ action: SubmitClaimsAction) -> SubmitClaimsState {
        var newState = state
        switch action {
        case let .setNewClaimId(id):
            if newState.currentClaimId != id {
                newState.currentClaimId = id
            }
        case .submitAudioRecording:
            setLoading(for: .postAudioRecording)
        case .resetAudioRecording:
            newState.audioRecordingStep?.audioContent = nil
        case let .stepModelAction(action):
            switch action {
            case let .setPhoneNumber(model):
                removeLoading(for: .postPhoneNumber)
                newState.phoneNumberStep = model
            case let .setSummaryStep(model):
                removeLoading(for: .postSummary)
                newState.summaryStep = model.summaryStep
                //                newState.locationStep = model.locationModel
                //                newState.dateOfOccurenceStep = model.dateOfOccurenceModel
                //                newState.singleItemStep = model.singleItemStepModel
                newState.audioRecordingStep = model.audioRecordingModel
                newState.fileUploadStep = model.fileUploadModel
            case let .setSingleItemCheckoutStep(model):
                removeLoading(for: .postSingleItemCheckout)
                newState.singleItemCheckoutStep = model
            case let .setFailedStep(model):
                newState.failedStep = model
                newState.progress = nil
            case let .setSuccessStep(model):
                newState.successStep = model
                newState.progress = nil
            case let .setAudioStep(model):
                removeLoading(for: .postAudioRecording)
                newState.audioRecordingStep = model
            case let .setContractSelectStep(model):
                removeLoading(for: .postContractSelect)
                newState.contractStep = model
            case let .setConfirmDeflectEmergencyStepModel(model):
                removeLoading(for: .postConfirmEmergency)
                newState.emergencyConfirm = model
            case let .setDeflectModel(model):
                newState.deflectStepModel = model
            case let .setFileUploadStep(model):
                removeLoading(for: .postUploadFiles)
                newState.fileUploadStep = model
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.send(.navigationAction(action: action.nextStepAction))
            }
        case let .setPayoutMethod(method):
            newState.singleItemCheckoutStep?.selectedPayoutMethod = method
        case .phoneNumberRequest:
            setLoading(for: .postPhoneNumber)
        case let .contractSelectRequest(selected):
            newState.contractStep?.selectedContractId = selected
            setLoading(for: .postContractSelect)
        case .summaryRequest:
            setLoading(for: .postSummary)
        case .singleItemCheckoutRequest:
            setLoading(for: .postSingleItemCheckout)
            newState.progress = nil
        case .emergencyConfirmRequest:
            setLoading(for: .postConfirmEmergency)
        case let .setProgress(progress):
            newState.previousProgress = newState.progress
            newState.progress = progress
        case let .setOnlyProgress(progress):
            newState.progress = progress
        case let .setOnlyPreviousProgress(progress):
            newState.previousProgress = progress
        default:
            break
        }
        return newState
    }
}
