import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

public final class SubmitClaimStore: LoadingStateStore<SubmitClaimsState, SubmitClaimsAction, ClaimsLoadingType> {
    @Inject var fileUploaderClient: FileUploaderClient
    @Inject var fetchEntrypointsService: hFetchEntrypointsService

    public override func effects(
        _ getState: @escaping () -> SubmitClaimsState,
        _ action: SubmitClaimsAction
    ) -> FiniteSignal<SubmitClaimsAction>? {
        let newClaimContext = state.currentClaimContext ?? ""
        switch action {
        case .submitClaimOpenFreeTextChat:
            return nil
        case let .startClaimRequest(entrypointId, entrypointOptionId):
            let startInput = OctopusGraphQL.FlowClaimStartInput(
                entrypointId: GraphQLNullable(optionalValue: entrypointId),
                entrypointOptionId: GraphQLNullable(optionalValue: entrypointOptionId)
            )
            let mutation = OctopusGraphQL.FlowClaimStartMutation(input: startInput, context: GraphQLNullable.none)
            return mutation.execute(\.flowClaimStart.fragments.flowClaimFragment.currentStep)
        case let .phoneNumberRequest(phoneNumberInput):
            let phoneNumber = OctopusGraphQL.FlowClaimPhoneNumberInput(phoneNumber: phoneNumberInput)
            let mutation = OctopusGraphQL.FlowClaimPhoneNumberNextMutation(input: phoneNumber, context: newClaimContext)
            return mutation.execute(\.flowClaimPhoneNumberNext.fragments.flowClaimFragment.currentStep)
        case .dateOfOccurrenceAndLocationRequest:
            if let dateOfOccurrenceStep = state.dateOfOccurenceStep, let locationStep = state.locationStep {
                let location = locationStep.getSelectedOption()?.value
                let date = dateOfOccurrenceStep.dateOfOccurence

                let dateAndLocationInput = OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationInput(
                    dateOfOccurrence: GraphQLNullable(optionalValue: date),
                    location: GraphQLNullable(optionalValue: location)
                )
                let mutation = OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationNextMutation(
                    input: dateAndLocationInput,
                    context: newClaimContext
                )
                return mutation.execute(
                    \.flowClaimDateOfOccurrencePlusLocationNext.fragments.flowClaimFragment.currentStep
                )
            } else if let dateOfOccurrenceStep = state.dateOfOccurenceStep {
                let dateString = dateOfOccurrenceStep.dateOfOccurence
                let dateOfOccurrenceInput = OctopusGraphQL.FlowClaimDateOfOccurrenceInput(
                    dateOfOccurrence: GraphQLNullable(optionalValue: dateString)
                )
                let mutation = OctopusGraphQL.FlowClaimDateOfOccurrenceNextMutation(
                    input: dateOfOccurrenceInput,
                    context: newClaimContext
                )
                return mutation.execute(\.flowClaimDateOfOccurrenceNext.fragments.flowClaimFragment.currentStep)
            } else if let locationStep = state.locationStep {
                let locationInput = OctopusGraphQL.FlowClaimLocationInput(
                    location: GraphQLNullable(optionalValue: locationStep.location)
                )
                let mutation = OctopusGraphQL.FlowClaimLocationNextMutation(
                    input: locationInput,
                    context: newClaimContext
                )
                return mutation.execute(\.flowClaimLocationNext.fragments.flowClaimFragment.currentStep)
            }
            return nil
        case let .submitAudioRecording(type):
            switch type {
            case .audio(let audioURL):
                return FiniteSignal { [unowned self] callback in
                    let disposeBag = DisposeBag()
                    do {
                        if let url = self.state.audioRecordingStep?.audioContent?.audioUrl {
                            let audioInput = OctopusGraphQL.FlowClaimAudioRecordingInput(
                                audioUrl: GraphQLNullable(optionalValue: url)
                            )
                            let mutation = OctopusGraphQL.FlowClaimAudioRecordingNextMutation(
                                input: audioInput,
                                context: newClaimContext
                            )
                            disposeBag +=
                                mutation.execute(\.flowClaimAudioRecordingNext.fragments.flowClaimFragment.currentStep)
                                .onValue({ action in
                                    callback(.value(action))
                                })
                        } else {
                            let data = try Data(contentsOf: audioURL)
                            let name = audioURL.lastPathComponent
                            let uploadFile = UploadFile(data: data, name: name, mimeType: "audio/x-m4a")
                            disposeBag += try self.fileUploaderClient
                                .upload(flowId: self.state.currentClaimId, file: uploadFile)
                                .onValue({ responseModel in
                                    let audioInput = OctopusGraphQL.FlowClaimAudioRecordingInput(
                                        audioUrl: GraphQLNullable(optionalValue: responseModel.audioUrl)
                                    )
                                    let mutation = OctopusGraphQL.FlowClaimAudioRecordingNextMutation(
                                        input: audioInput,
                                        context: newClaimContext
                                    )
                                    disposeBag +=
                                        mutation.execute(
                                            \.flowClaimAudioRecordingNext.fragments.flowClaimFragment.currentStep
                                        )
                                        .onValue({ action in
                                            callback(.value(action))
                                        })
                                })
                                .onError({ [weak self] error in
                                    self?.setError(L10n.General.errorBody, for: .postAudioRecording)
                                })
                                .disposable
                        }
                    } catch _ {
                        self.setError(L10n.General.errorBody, for: .postAudioRecording)
                    }
                    return disposeBag
                }
            case let .text(text):
                let audioInput = OctopusGraphQL.FlowClaimAudioRecordingInput(
                    freeText: GraphQLNullable(optionalValue: text)
                )
                let mutation = OctopusGraphQL.FlowClaimAudioRecordingNextMutation(
                    input: audioInput,
                    context: newClaimContext
                )
                return mutation.execute(\.flowClaimAudioRecordingNext.fragments.flowClaimFragment.currentStep)
            }
        case let .submitDamage(damages):
            return FiniteSignal { callback in
                callback(.value(.setSingleItemDamage(damages: damages)))
                return NilDisposer()
            }

        case let .singleItemRequest(purchasePrice):
            let singleItemInput = state.singleItemStep!.returnSingleItemInfo(purchasePrice: purchasePrice)
            let mutation = OctopusGraphQL.FlowClaimSingleItemNextMutation(
                input: singleItemInput,
                context: newClaimContext
            )
            return mutation.execute(\.flowClaimSingleItemNext.fragments.flowClaimFragment.currentStep)
        case .summaryRequest:
            let summaryInput = OctopusGraphQL.FlowClaimSummaryInput()
            let mutation = OctopusGraphQL.FlowClaimSummaryNextMutation(
                input: summaryInput,
                context: newClaimContext
            )
            return mutation.execute(\.flowClaimSummaryNext.fragments.flowClaimFragment.currentStep)
        case .singleItemCheckoutRequest:
            if let claimSingleItemCheckoutInput = self.state.singleItemCheckoutStep?.returnSingleItemCheckoutInfo() {
                let mutation = OctopusGraphQL.FlowClaimSingleItemCheckoutNextMutation(
                    input: claimSingleItemCheckoutInput,
                    context: newClaimContext
                )
                return mutation.execute(\.flowClaimSingleItemCheckoutNext.fragments.flowClaimFragment.currentStep)
            } else {
                return FiniteSignal { callback in
                    let disposeBag = DisposeBag()
                    self.setError(L10n.General.errorBody, for: .postSingleItemCheckout)
                    return disposeBag
                }
            }
        case let .contractSelectRequest(contractId):
            let contractSelectInput = OctopusGraphQL.FlowClaimContractSelectInput(
                contractId: GraphQLNullable(optionalValue: contractId)
            )
            let mutation = OctopusGraphQL.FlowClaimContractSelectNextMutation(
                input: contractSelectInput,
                context: newClaimContext
            )
            return mutation.execute(\.flowClaimContractSelectNext.fragments.flowClaimFragment.currentStep)
        case .fetchEntrypointGroups:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                Task {
                    do {
                        let data = try await self.fetchEntrypointsService.get()
                        callback(.value(.setClaimEntrypointGroupsForSelection(data)))

                    } catch {
                        callback(
                            .value(
                                .setLoadingState(action: action, state: .error(error: L10n.General.errorBody))
                            )
                        )
                    }
                }
                return disposeBag
            }
        case let .emergencyConfirmRequest(isEmergency):
            let confirmEmergencyInput = OctopusGraphQL.FlowClaimConfirmEmergencyInput(confirmEmergency: isEmergency)
            let mutation = OctopusGraphQL.FlowClaimConfirmEmergencyNextMutation(
                input: confirmEmergencyInput,
                context: GraphQLNullable(optionalValue: newClaimContext)
            )
            return mutation.execute(\.flowClaimConfirmEmergencyNext.fragments.flowClaimFragment.currentStep)
        case let .submitFileUpload(ids):
            let input = OctopusGraphQL.FlowClaimFileUploadInput(fileIds: ids)
            let mutation = OctopusGraphQL.FlowClaimFileUploadNextMutation(input: input, context: newClaimContext)
            return mutation.execute(\.flowClaimFileUploadNext.fragments.flowClaimFragment.currentStep)
        default:
            return nil
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
        case let .setSingleItemModel(model):
            if let customName = model.customName {
                newState.singleItemStep?.customName = customName
            } else {
                newState.singleItemStep?.customName = nil
                newState.singleItemStep?.selectedItemModel = model.itemModelId
            }
        case let .setPurchasePrice(priceOfPurchase):
            newState.singleItemStep?.purchasePrice = priceOfPurchase
        case let .setSingleItemPurchaseDate(purchaseDate):
            newState.singleItemStep?.purchaseDate = purchaseDate?.localDateString
        case let .setItemBrand(brand):
            newState.singleItemStep?.selectedItemModel = nil
            newState.singleItemStep?.selectedItemBrand = brand.itemBrandId
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
                switch model.id {
                case .FlowClaimDeflectGlassDamageStep:
                    newState.glassDamageStep = model
                case .FlowClaimDeflectPestsStep:
                    newState.pestsStep = model
                case .FlowClaimDeflectEmergencyStep:
                    newState.emergencyStep = model
                default:
                    break
                }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.setLoading(for: .fetchClaimEntrypointGroups)
            }
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
}
