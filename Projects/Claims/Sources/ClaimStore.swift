import Apollo
import Flow
import Odyssey
import Presentation
import SwiftUI
import hCore
import hGraphQL

public final class ClaimsStore: StateStore<ClaimsState, ClaimsAction> {

    @Inject var giraffe: hGiraffe
    @Inject var octopus: hOctopus
    @Inject var store: ApolloStore
    @Inject var fileUploaderClient: FileUploaderClient

    public override func effects(
        _ getState: @escaping () -> ClaimsState,
        _ action: ClaimsAction
    ) -> FiniteSignal<ClaimsAction>? {
        let newClaimContext = state.currentClaimContext ?? ""
        switch action {
        case .openFreeTextChat:
            return nil
        case .fetchClaims:
            return giraffe
                .client
                .fetch(
                    query: GiraffeGraphQL.ClaimStatusCardsQuery(
                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
                    ),
                    cachePolicy: .fetchIgnoringCacheData
                )
                .compactMap {
                    ClaimData(cardData: $0)
                }
                .map { claimData in
                    return .setClaims(claims: claimData.claims)
                }
                .valueThenEndSignal
        case .fetchCommonClaims:
            return
                giraffe.client
                .fetch(
                    query: GiraffeGraphQL.CommonClaimsQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale())
                )
                .map { data in
                    let commonClaims = data.commonClaims.map {
                        CommonClaim(claim: $0)
                    }
                    return .setCommonClaims(commonClaims: commonClaims)
                }
                .valueThenEndSignal
        case let .startClaimRequest(id):
            self.send(.setLoadingState(action: .startClaim, state: .loading))
            let startInput = OctopusGraphQL.FlowClaimStartInput(entrypointId: id)
            let mutation = OctopusGraphQL.FlowClaimStartMutation(input: startInput)
            return mutation.execute(\.flowClaimStart.fragments.flowClaimFragment.currentStep)
        case let .claimNextPhoneNumber(phoneNumberInput):
            self.send(.setLoadingState(action: .postPhoneNumber, state: .loading))
            let phoneNumber = OctopusGraphQL.FlowClaimPhoneNumberInput(phoneNumber: phoneNumberInput)
            let mutation = OctopusGraphQL.FlowClaimPhoneNumberNextMutation(input: phoneNumber, context: newClaimContext)
            return mutation.execute(\.flowClaimPhoneNumberNext.fragments.flowClaimFragment.currentStep)
        case let .claimNextDateOfOccurrence(dateOfOccurrence):
            send(.setLoadingState(action: .postDateOfOccurrence, state: .loading))
            let dateString = dateOfOccurrence?.localDateString
            let dateOfOccurrenceInput = OctopusGraphQL.FlowClaimDateOfOccurrenceInput(dateOfOccurrence: dateString)
            let mutation = OctopusGraphQL.FlowClaimDateOfOccurrenceNextMutation(
                input: dateOfOccurrenceInput,
                context: newClaimContext
            )
            return mutation.execute(\.flowClaimDateOfOccurrenceNext.fragments.flowClaimFragment.currentStep)
        case let .claimNextLocation(location):
            self.send(.setLoadingState(action: .postLocation, state: .loading))
            let locationInput = OctopusGraphQL.FlowClaimLocationInput(location: location)
            let mutation = OctopusGraphQL.FlowClaimLocationNextMutation(input: locationInput, context: newClaimContext)
            return mutation.execute(\.flowClaimLocationNext.fragments.flowClaimFragment.currentStep)
        case .claimNextDateOfOccurrenceAndLocation:
            self.send(.setLoadingState(action: .postDateOfOccurrenceAndLocation, state: .loading))
            let location = state.locationStep?.getSelectedOption()?.value
            let date = state.dateOfOccurenceStep?.dateOfOccurence

            let dateAndLocationInput = OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationInput(
                dateOfOccurrence: date,
                location: location
            )
            let mutation = OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationNextMutation(
                input: dateAndLocationInput,
                context: newClaimContext
            )
            return mutation.execute(\.flowClaimDateOfOccurrencePlusLocationNext.fragments.flowClaimFragment.currentStep)
        case let .submitAudioRecording(audioURL):
            self.send(.setLoadingState(action: .postAudioRecording, state: .loading))
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                do {
                    let data = try Data(contentsOf: audioURL)
                    let name = audioURL.lastPathComponent
                    let uploadFile = UploadFile(data: data, name: name, mimeType: "audio/x-m4a")
                    disposeBag += try self.fileUploaderClient
                        .upload(flowId: self.state.currentClaimId, file: uploadFile)
                        .onValue({ responseModel in
                            //todo
                            let audioInput = OctopusGraphQL.FlowClaimAudioRecordingInput(
                                audioUrl: responseModel.audioUrl
                            )
                            let mutation = OctopusGraphQL.FlowClaimAudioRecordingNextMutation(
                                input: audioInput,
                                context: newClaimContext
                            )
                            disposeBag += mutation.execute(\.flowClaimAudioRecordingNext.fragments.flowClaimFragment.currentStep).onValue({ action in
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

        case let .claimNextSingleItem(purchasePrice):
            self.send(.setLoadingState(action: .postSingleItem, state: .loading))
            let singleItemInput = state.singleItemStep!.returnSingleItemInfo(purchasePrice: purchasePrice)
            let mutation = OctopusGraphQL.FlowClaimSingleItemNextMutation(
                input: singleItemInput,
                context: newClaimContext
            )
            return mutation.execute(\.flowClaimSingleItemNext.fragments.flowClaimFragment.currentStep)
        case .claimNextSummary:
            send(.setLoadingState(action: .postSummary, state: .loading))
            let summaryInput = OctopusGraphQL.FlowClaimSummaryInput()
            let mutation = OctopusGraphQL.FlowClaimSummaryNextMutation(
                input: summaryInput,
                context: newClaimContext
            )
            return mutation.execute(\.flowClaimSummaryNext.fragments.flowClaimFragment.currentStep)
        case .claimNextSingleItemCheckout:
            send(.setLoadingState(action: .postSingleItemCheckout, state: .loading))
            if let claimSingleItemCheckoutInput = self.state.singleItemCheckoutStep!.returnSingleItemCheckoutInfo() {
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
        case .fetchCommonClaimsForSelection:
            self.send(.setLoadingState(action: .fetchCommonClaims, state: .loading))
            let entryPointInput = OctopusGraphQL.EntrypointSearchInput(type: OctopusGraphQL.EntrypointType.claim)
            let query = OctopusGraphQL.EntrypointSearchQuery(input: entryPointInput)
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag +=
                    self.octopus.client.fetch(query: query)
                    .onValue { data in
                        let model = data.entrypointSearch.map {
                            ClaimEntryPointResponseModel(id: $0.id, displayName: $0.displayName)
                        }

                        callback(.value(.setCommonClaimsForSelection(model)))
                        callback(.value(.setLoadingState(action: .fetchCommonClaims, state: nil)))
                    }
                    .onError { error in
                        callback(
                            .value(
                                .setLoadingState(
                                    action: .fetchCommonClaims,
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

    public override func reduce(_ state: ClaimsState, _ action: ClaimsAction) -> ClaimsState {
        var newState = state
        switch action {
        case let .setClaims(claims):
            newState.claims = claims
        case let .setCommonClaims(commonClaims):
            newState.commonClaims = commonClaims
        case let .setNewClaimId(id):
            newState.currentClaimId = id
        case let .setNewLocation(location):
            newState.locationStep?.location = location
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
        case let .setCommonClaimsForSelection(commonClaims):
            newState.entryPointCommonClaims = commonClaims
        case let .submitAudioRecording(url):
            newState.audioRecordingStep?.url = url
        case let .stepModelAction(action):
            switch action {
            case let .setPhoneNumber(model):
                newState.phoneNumberStep = model
                send(.navigationAction(action: .openPhoneNumberScreen(model: model)))
            case let .setDateOfOccurrencePlusLocation(model):
                newState.dateOfOccurrencePlusLocationStep = model.dateOfOccurencePlusLocationModel
                newState.locationStep = model.locationModel
                newState.dateOfOccurenceStep = model.dateOfOccurenceModel
            case let .setDateOfOccurence(model):
                newState.dateOfOccurenceStep = model
            case let .setLocation(model):
                newState.locationStep = model
            case let .setSingleItem(model):
                newState.singleItemStep = model
            case let .setSummaryStep(model):
                newState.summaryStep = model
            case let .setSingleItemCheckoutStep(model):
                newState.singleItemCheckoutStep = model
            case let .setFailedStep(model):
                newState.failedStep = model
            case let .setSuccessStep(model):
                newState.successStep = model
            case let .setAudioStep(model):
                newState.audioRecordingStep = model
            }
        case .startClaimRequest:
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
        default:
            break
        }
        return newState
    }
}
