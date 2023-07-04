import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

public final class SubmitClaimStore: StateStore<SubmitClaimsState, SubmitClaimsAction> {

    @Inject var octopus: hOctopus
    @Inject var fileUploaderClient: FileUploaderClient

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
                entrypointId: entrypointId,
                entrypointOptionId: entrypointOptionId
            )
            let mutation = OctopusGraphQL.FlowClaimStartMutation(input: startInput)
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
                    dateOfOccurrence: date,
                    location: location
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
                let dateOfOccurrenceInput = OctopusGraphQL.FlowClaimDateOfOccurrenceInput(dateOfOccurrence: dateString)
                let mutation = OctopusGraphQL.FlowClaimDateOfOccurrenceNextMutation(
                    input: dateOfOccurrenceInput,
                    context: newClaimContext
                )
                return mutation.execute(\.flowClaimDateOfOccurrenceNext.fragments.flowClaimFragment.currentStep)
            } else if let locationStep = state.locationStep {
                let locationInput = OctopusGraphQL.FlowClaimLocationInput(location: locationStep.location)
                let mutation = OctopusGraphQL.FlowClaimLocationNextMutation(
                    input: locationInput,
                    context: newClaimContext
                )
                return mutation.execute(\.flowClaimLocationNext.fragments.flowClaimFragment.currentStep)
            }
            return nil

        case let .submitAudioRecording(audioURL):
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                do {
                    if let url = self.state.audioRecordingStep?.audioContent?.audioUrl {
                        let audioInput = OctopusGraphQL.FlowClaimAudioRecordingInput(
                            audioUrl: url
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
                                    audioUrl: responseModel.audioUrl
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
                            .onError({ error in
                                callback(
                                    .value(
                                        .setLoadingState(
                                            action: .postAudioRecording,
                                            state: .error(error: L10n.General.errorBody)
                                        )
                                    )
                                )
                            })
                            .disposable
                    }
                } catch _ {
                    callback(
                        .value(
                            .setLoadingState(
                                action: .postAudioRecording,
                                state: .error(error: L10n.General.errorBody)
                            )
                        )
                    )
                }

                return disposeBag
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
                    callback(
                        .value(
                            .setLoadingState(
                                action: .postSingleItemCheckout,
                                state: .error(error: L10n.General.errorBody)
                            )
                        )
                    )
                    return disposeBag
                }
            }
        case .fetchEntrypointGroups:
            let entrypointType = OctopusGraphQL.EntrypointType.claim
            let query = OctopusGraphQL.EntrypointGroupsQuery(type: entrypointType)
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag +=
                    self.octopus.client.fetch(query: query)
                    .onValue { data in
                        let model = data.entrypointGroups.map { data in
                            ClaimEntryPointGroupResponseModel(with: data.fragments.entrypointGroupFragment)
                        }
                        callback(.value(.setClaimEntrypointGroupsForSelection(model)))
                        callback(.value(.setLoadingState(action: .fetchClaimEntrypointGroups, state: nil)))
                    }
                    .onError { error in
                        callback(
                            .value(
                                .setLoadingState(
                                    action: .fetchClaimEntrypointGroups,
                                    state: .error(error: L10n.General.errorBody)
                                )
                            )
                        )
                    }
                    .disposable
                return disposeBag
            }

        case let .fetchClaimEntrypointsForSelection(entrypointGroupId):
            var entryPointInput: OctopusGraphQL.EntrypointSearchInput

            if let entrypointGroupId = entrypointGroupId {
                entryPointInput = OctopusGraphQL.EntrypointSearchInput(
                    entrypointGroupId: entrypointGroupId,
                    type: OctopusGraphQL.EntrypointType.claim
                )
            } else {
                entryPointInput = OctopusGraphQL.EntrypointSearchInput(
                    type: OctopusGraphQL.EntrypointType.claim
                )
            }

            let query = OctopusGraphQL.EntrypointSearchQuery(input: entryPointInput)
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag +=
                    self.octopus.client.fetch(query: query)
                    .onValue { data in
                        let model = data.entrypointSearch.map { data in
                            ClaimEntryPointResponseModel(with: data.fragments.entrypointFragment)
                        }

                        callback(.value(.setClaimEntrypointsForSelection(model)))
                        callback(.value(.setLoadingState(action: .fetchClaimEntrypoints, state: nil)))
                    }
                    .onError { error in
                        callback(
                            .value(
                                .setLoadingState(
                                    action: .fetchClaimEntrypoints,
                                    state: .error(error: L10n.General.errorBody)
                                )
                            )
                        )
                    }
                    .disposable
                return disposeBag
            }
        default:
            return nil
        }
    }

    public override func reduce(_ state: SubmitClaimsState, _ action: SubmitClaimsAction) -> SubmitClaimsState {
        var newState = state
        switch action {
        case let .setNewClaimId(id):
            newState.currentClaimId = id
        case let .setNewLocation(location):
            newState.locationStep?.location = location?.value
        case let .setNewDate(dateOfOccurrence):
            newState.dateOfOccurenceStep?.dateOfOccurence = dateOfOccurrence
        case let .setSingleItemDamage(damages):
            newState.singleItemStep?.selectedItemProblems = damages
        case let .setSingleItemModel(model):
            newState.singleItemStep?.selectedItemModel = model.itemModelId
        case let .setPurchasePrice(priceOfPurchase):
            newState.singleItemStep?.purchasePrice = priceOfPurchase
        case let .setSingleItemPurchaseDate(purchaseDate):
            newState.singleItemStep?.purchaseDate = purchaseDate?.localDateString
        case let .setItemBrand(brand):
            newState.singleItemStep?.selectedItemModel = nil
            newState.singleItemStep?.selectedItemBrand = brand.itemBrandId
        case let .setLoadingState(action, state):
            if let state {
                newState.loadingStates[action] = state
            } else {
                newState.loadingStates.removeValue(forKey: action)
            }
        case let .setNewClaimContext(context):
            newState.currentClaimContext = context
        case let .setClaimEntrypointsForSelection(commonClaims):
            newState.claimEntrypoints = commonClaims
        case let .setClaimEntrypointGroupsForSelection(entrypointGroups):
            newState.claimEntrypointGroups = entrypointGroups
        case .submitAudioRecording:
            newState.loadingStates[.postAudioRecording] = .loading
        case .resetAudioRecording:
            newState.audioRecordingStep?.audioContent = nil
        case let .stepModelAction(action):
            switch action {
            case let .setPhoneNumber(model):
                newState.phoneNumberStep = model
                send(.navigationAction(action: .openPhoneNumberScreen(model: model)))
            case let .setDateOfOccurrencePlusLocation(model):
                newState.dateOfOccurrencePlusLocationStep = model.dateOfOccurencePlusLocationModel
                newState.locationStep = model.locationModel
                newState.dateOfOccurenceStep = model.dateOfOccurenceModel
                send(.navigationAction(action: .openDateOfOccurrencePlusLocationScreen(type: .locationAndDate)))
            case let .setDateOfOccurence(model):
                newState.dateOfOccurenceStep = model
                send(.navigationAction(action: .openDateOfOccurrencePlusLocationScreen(type: .date)))
            case let .setLocation(model):
                newState.locationStep = model
                send(.navigationAction(action: .openDateOfOccurrencePlusLocationScreen(type: .location)))
            case let .setSingleItem(model):
                newState.singleItemStep = model
                send(.navigationAction(action: .openSingleItemScreen))
            case let .setSummaryStep(model):
                newState.summaryStep = model.summaryStep
                newState.locationStep = model.locationModel
                newState.dateOfOccurenceStep = model.dateOfOccurenceModel
                newState.singleItemStep = model.singleItemStepModel
                send(.navigationAction(action: .openSummaryScreen))
            case let .setSingleItemCheckoutStep(model):
                newState.singleItemCheckoutStep = model
                send(.navigationAction(action: .openCheckoutNoRepairScreen))
            case let .setFailedStep(model):
                newState.failedStep = model
                send(.navigationAction(action: .openFailureSceen))
                newState.progress = nil
            case let .setSuccessStep(model):
                newState.successStep = model
                newState.progress = nil
                send(.navigationAction(action: .openSuccessScreen))
            case let .setAudioStep(model):
                newState.audioRecordingStep = model
                send(.navigationAction(action: .openAudioRecordingScreen))
            }
        case .startClaimRequest:
            newState.loadingStates[.startClaim] = .loading
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
            newState.currentClaimContext = nil
        case let .setPayoutMethod(method):
            newState.singleItemCheckoutStep?.selectedPayoutMethod = method
        case .phoneNumberRequest:
            newState.loadingStates[.postPhoneNumber] = .loading
        case .dateOfOccurrenceRequest:
            newState.loadingStates[.postDateOfOccurrence] = .loading
        case .locationRequest:
            newState.loadingStates[.postLocation] = .loading
        case .dateOfOccurrenceAndLocationRequest:
            newState.loadingStates[.postDateOfOccurrenceAndLocation] = .loading
        case .singleItemRequest:
            newState.loadingStates[.postSingleItem] = .loading
        case .summaryRequest:
            newState.loadingStates[.postSummary] = .loading
        case .singleItemCheckoutRequest:
            newState.loadingStates[.postSingleItemCheckout] = .loading
            newState.progress = nil
        case .fetchClaimEntrypointsForSelection:
            newState.loadingStates[.fetchClaimEntrypoints] = .loading
        case .fetchEntrypointGroups:
            newState.loadingStates[.fetchClaimEntrypointGroups] = .loading
            newState.progress = nil
        case let .setSelectedEntrypoints(entrypoints):
            newState.entrypoints.selectedEntrypoints = entrypoints
        case let .setSelectedEntrypointOptions(entrypointOptions):
            newState.entrypoints.selectedEntrypointOptions = entrypointOptions
        case let .setSelectedEntrypointId(entrypointId):
            newState.entrypoints.selectedEntrypointId = entrypointId
        case let .setProgress(progress):
            newState.previousProgress = newState.progress
            newState.progress = progress
        default:
            break
        }
        return newState
    }
}
