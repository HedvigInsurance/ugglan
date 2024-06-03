import Apollo
import Combine
import Flow
import Presentation
import SwiftUI
import hCore

public final class SubmitClaimStore: LoadingStateStore<SubmitClaimsState, SubmitClaimsAction, ClaimsLoadingType> {
    @Inject var fileUploaderClient: FileUploaderClient
    @Inject var fetchEntrypointsService: hFetchEntrypointsClient
    @Inject var submitClaimService: SubmitClaimClient
    var progressCancellable: AnyCancellable?
    public override func effects(
        _ getState: @escaping () -> SubmitClaimsState,
        _ action: SubmitClaimsAction
    ) async {
        let newClaimContext = state.currentClaimContext ?? ""
        switch action {
        case .submitClaimOpenFreeTextChat:
            break
        case let .startClaimRequest(entrypointId, entrypointOptionId):
            await executeAsync(loadingType: .startClaim) {
                try await self.submitClaimService.startClaim(
                    entrypointId: entrypointId,
                    entrypointOptionId: entrypointOptionId
                )
            }
        case let .phoneNumberRequest(phoneNumberInput):
            await executeAsync(loadingType: .postPhoneNumber) {
                try await self.submitClaimService.updateContact(phoneNumber: phoneNumberInput, context: newClaimContext)
            }
        case .dateOfOccurrenceAndLocationRequest:
            await executeAsync(loadingType: .postDateOfOccurrenceAndLocation) {
                try await self.submitClaimService.dateOfOccurrenceAndLocationRequest(context: newClaimContext)
            }
        case let .submitAudioRecording(type):
            await executeAsync(loadingType: .postAudioRecording) {
                try await self.submitClaimService.submitAudioRecording(
                    type: type,
                    fileUploaderClient: self.fileUploaderClient,
                    context: newClaimContext
                )
            }
        case let .singleItemRequest(purchasePrice):
            await executeAsync(loadingType: .postSingleItem) {
                try await self.submitClaimService.singleItemRequest(
                    purchasePrice: purchasePrice,
                    context: newClaimContext
                )
            }
        case .summaryRequest:
            await executeAsync(loadingType: .postSummary) {
                try await self.submitClaimService.summaryRequest(context: newClaimContext)
            }
        case .singleItemCheckoutRequest:
            await executeAsync(loadingType: .postSingleItemCheckout) {
                try await self.submitClaimService.singleItemCheckoutRequest(context: newClaimContext)
            }

        case let .contractSelectRequest(contractId):
            await executeAsync(loadingType: .postContractSelect) {
                try await self.submitClaimService.contractSelectRequest(
                    contractId: contractId ?? "",
                    context: newClaimContext
                )
            }

        case .fetchEntrypointGroups:
            do {
                let data = try await self.fetchEntrypointsService.get()
                send(.setClaimEntrypointGroupsForSelection(data))
            } catch {
                setError(L10n.General.errorBody, for: .fetchClaimEntrypointGroups)
            }
        case let .emergencyConfirmRequest(isEmergency):
            await executeAsync(loadingType: .postConfirmEmergency) {
                try await self.submitClaimService.emergencyConfirmRequest(
                    isEmergency: isEmergency,
                    context: newClaimContext
                )
            }
        case let .submitFileUpload(ids):
            await executeAsync(loadingType: .postUploadFiles) {
                try await self.submitClaimService.submitFileUpload(ids: ids, context: newClaimContext)
            }
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
        case let .setNewLocation(location):
            newState.locationStep?.location = location?.value
        case let .setNewDate(dateOfOccurrence):
            newState.dateOfOccurenceStep?.dateOfOccurence = dateOfOccurrence
        case let .setSingleItemDamage(damages):
            newState.singleItemStep?.selectedItemProblems = damages
        case let .setItemModel(model):
            switch model {
            case let .model(model):
                newState.singleItemStep?.selectedItemBrand = model.itemBrandId
                newState.singleItemStep?.customName = nil
                newState.singleItemStep?.selectedItemModel = model.itemModelId
            case let .custom(brand, name):
                newState.singleItemStep?.selectedItemBrand = brand.itemBrandId
                newState.singleItemStep?.customName = name
                newState.singleItemStep?.selectedItemModel = nil
            }
        case let .setPurchasePrice(priceOfPurchase):
            newState.singleItemStep?.purchasePrice = priceOfPurchase
        case let .setSingleItemPurchaseDate(purchaseDate):
            newState.singleItemStep?.purchaseDate = purchaseDate?.localDateString
        case let .setNewClaimContext(context):
            newState.currentClaimContext = context
        case let .setClaimEntrypointsForSelection(commonClaims):
            newState.claimEntrypoints = commonClaims
        case let .setClaimEntrypointGroupsForSelection(entrypointGroups):
            newState.claimEntrypointGroups = entrypointGroups
            removeLoading(for: .fetchClaimEntrypointGroups)
        case .submitAudioRecording:
            setLoading(for: .postAudioRecording)
        case .resetAudioRecording:
            newState.audioRecordingStep?.audioContent = nil
        case let .stepModelAction(action):
            switch action {
            case let .setPhoneNumber(model):
                removeLoading(for: .postPhoneNumber)
                newState.phoneNumberStep = model
            case let .setDateOfOccurrencePlusLocation(model):
                removeLoading(for: .postDateOfOccurrenceAndLocation)
                newState.dateOfOccurrencePlusLocationStep = model.dateOfOccurencePlusLocationModel
                newState.locationStep = model.locationModel
                newState.dateOfOccurenceStep = model.dateOfOccurenceModel
            case let .setDateOfOccurence(model):
                removeLoading(for: .postDateOfOccurrenceAndLocation)
                newState.dateOfOccurenceStep = model
            case let .setLocation(model):
                removeLoading(for: .postDateOfOccurrenceAndLocation)
                newState.locationStep = model
            case let .setSingleItem(model):
                removeLoading(for: .postSingleItem)
                newState.singleItemStep = model
            case let .setSummaryStep(model):
                removeLoading(for: .postSummary)
                newState.summaryStep = model.summaryStep
                newState.locationStep = model.locationModel
                newState.dateOfOccurenceStep = model.dateOfOccurenceModel
                newState.singleItemStep = model.singleItemStepModel
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
        case .startClaimRequest:
            setLoading(for: .startClaim)
            newState.summaryStep = nil
            newState.dateOfOccurenceStep = nil
            newState.locationStep = nil
            newState.singleItemStep = nil
            newState.phoneNumberStep = nil
            newState.dateOfOccurrencePlusLocationStep = nil
            newState.singleItemCheckoutStep = nil
            newState.successStep = nil
            newState.failedStep = nil
            newState.audioRecordingStep = nil
            newState.contractStep = nil
            newState.currentClaimContext = nil
            newState.fileUploadStep = nil
        case let .setPayoutMethod(method):
            newState.singleItemCheckoutStep?.selectedPayoutMethod = method
        case .phoneNumberRequest:
            setLoading(for: .postPhoneNumber)
        case .dateOfOccurrenceAndLocationRequest:
            setLoading(for: .postDateOfOccurrenceAndLocation)
        case let .contractSelectRequest(selected):
            newState.contractStep?.selectedContractId = selected
            setLoading(for: .postContractSelect)
        case .singleItemRequest:
            setLoading(for: .postSingleItem)
        case .summaryRequest:
            setLoading(for: .postSummary)
        case .singleItemCheckoutRequest:
            setLoading(for: .postSingleItemCheckout)
            newState.progress = nil
        case .emergencyConfirmRequest:
            setLoading(for: .postConfirmEmergency)
        case .fetchEntrypointGroups:
            setLoading(for: .fetchClaimEntrypointGroups)
            newState.progress = 0
            newState.previousProgress = 0
        case let .setSelectedEntrypoints(entrypoints):
            newState.previousProgress = 0
            if entrypoints.isEmpty {
                newState.entrypoints.selectedEntrypoints = entrypoints
                send(
                    .startClaimRequest(
                        entrypointId: nil,
                        entrypointOptionId: nil
                    )
                )
            } else {
                if entrypoints.first?.options == [] {
                    newState.progress = 0.2
                } else {
                    newState.progress = 0.1
                }
                newState.entrypoints.selectedEntrypoints = entrypoints
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                    self?.send(.navigationAction(action: .openTriagingEntrypointScreen))
                }
            }
        case let .setSelectedEntrypointOptions(entrypointOptions, selectedEntrypointId):
            newState.previousProgress = newState.progress
            newState.progress = 0.2
            newState.entrypoints.selectedEntrypointOptions = entrypointOptions
            newState.entrypoints.selectedEntrypointId = selectedEntrypointId
            if entrypointOptions.isEmpty {
                send(
                    .startClaimRequest(
                        entrypointId: selectedEntrypointId,
                        entrypointOptionId: nil
                    )
                )
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                    self?.send(.navigationAction(action: .openTriagingOptionScreen))
                }
            }
        case let .setProgress(progress):
            newState.previousProgress = newState.progress
            newState.progress = progress
        default:
            break
        }
        return newState
    }

    private func executeAsync(
        loadingType: ClaimsLoadingType,
        action: @escaping () async throws -> SubmitClaimStepResponse
    ) async {
        self.setLoading(for: loadingType)
        do {
            let data = try await action()
            await sendAsync(.setNewClaimId(with: data.claimId))
            await sendAsync(.setNewClaimContext(context: data.context))
            if let progress = data.progress {
                await sendAsync(.setProgress(progress: progress))
            }
            await sendAsync(data.action)
            removeLoading(for: loadingType)
        } catch let error {
            self.setError(error.localizedDescription, for: loadingType)
        }
    }
}
