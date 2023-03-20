import Apollo
import Contracts
import Flow
import Odyssey
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct ClaimsState: StateProtocol {
    var claims: [Claim]? = nil
    var commonClaims: [CommonClaim]? = nil
    var newClaim: NewClaim = .init(id: "")

    public init() {}

    public var hasActiveClaims: Bool {
        if let claims = claims {
            return
                !claims.filter {
                    $0.claimDetailData.status == .beingHandled || $0.claimDetailData.status == .reopened
                        || $0.claimDetailData.status == .submitted
                }
                .isEmpty
        }
        return false
    }
}

public enum ClaimsAction: ActionProtocol {
    case openFreeTextChat
    case submitNewClaim(from: ClaimsOrigin)
    case fetchClaims
    case setClaims(claims: [Claim])
    case fetchCommonClaims
    case setCommonClaims(commonClaims: [CommonClaim])
    case openCommonClaimDetail(commonClaim: CommonClaim)
    case openHowClaimsWork
    case openClaimDetails(claim: Claim)
    case odysseyRedirect(url: String)

    case dissmissNewClaimFlow

    case openPhoneNumberScreen(context: String, phoneNumber: String)
    case submitClaimPhoneNumber(phoneNumberInput: String)

    case openDateOfOccurrenceScreen(context: String)
    case openLocationPicker(context: String)
    case openDatePicker

    case submitClaimDateOfOccurrence(dateOfOccurrence: Date)
    case submitClaimLocation(displayValue: String, value: String)

    case submitOccuranceAndLocation
    case submitAudioRecording(audioURL: URL)
    case submitSingleItem(purchasePrice: Double)
    case submitDamage(damage: [NewClaimsInfo])
    case claimNextDamage(damages: NewClaimsInfo)
    case submitModel(model: Model)
    case submitBrand(brand: Brand)

    case openSuccessScreen(context: String)
    case openSingleItemScreen(context: String)
    case openSummaryScreen
    case openSummaryEditScreen
    case openDamagePickerScreen
    case openModelPicker
    case openBrandPicker
    case openCheckoutNoRepairScreen
    case openCheckoutTransferringScreen
    case openCheckoutTransferringDoneScreen
    case openAudioRecordingScreen(context: String)

    case startClaim(from: ClaimsOrigin)
    case setNewClaim(from: NewClaim)
    case claimNextPhoneNumber(phoneNumber: String, context: String)
    case claimNextDateOfOccurrence(dateOfOccurrence: Date, context: String)
    case claimNextLocation(displayName: String, displayValue: String, context: String)
    case claimNextDateOfOccurrenceAndLocation(context: String)
    case claimNextAudioRecording(audioURL: URL, context: String)
    case claimNextSingleItem(context: String, purchasePrice: Double)

    case setNewLocation(location: NewClaimsInfo?)
    case setNewDate(dateOfOccurrence: String?)
    case setListOfLocations(displayValues: [NewClaimsInfo])
    case setPurchasePrice(priceOfPurchase: Double)
    case setSingleItemLists(brands: [Brand], models: [Model], damages: [NewClaimsInfo])
    case setSingleItemModel(modelName: Model)
    case setSingleItemPriceOfPurchase(purchasePrice: Double)
    case setSingleItemDamage(damages: [NewClaimsInfo])
    case setSingleItemPurchaseDate(purchaseDate: Date)
    case setSingleItemBrand(brand: Brand)
}

public enum ClaimsOrigin: Codable, Equatable {
    case generic
    case commonClaims(id: String)

    public var initialScopeValues: ScopeValues {
        let scopeValues = ScopeValues()
        switch self {
        case let .commonClaims(id):
            scopeValues.setValue(
                key: CommonClaimIdScopeValueKey.shared,
                value: id
            )
        default:
            break
        }
        return scopeValues
    }
}

public final class ClaimsStore: StateStore<ClaimsState, ClaimsAction> {

    @Inject var giraffe: hGiraffe
    @Inject var octopus: hOctopus
    @Inject var store: ApolloStore
    @Inject var fileUploaderClient: FileUploaderClient
    
    public override func effects(
        _ getState: @escaping () -> ClaimsState,
        _ action: ClaimsAction
    ) -> FiniteSignal<ClaimsAction>? {
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

        case let .startClaim(claimsOrigin):

            let startInput = OctopusGraphQL.FlowClaimStartInput(entrypointId: "5dddcab9-a0fc-4cb7-94f3-2785693e8803")  //need to be UUID

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.FlowClaimStartMutation(input: startInput)  // 5dddcab9-a0fc-4cb7-94f3-2785693e8803
                    )
                    .onValue { data in
                        let id = data.flowClaimStart.id
                        let contextInput = data.flowClaimStart.context
                        let data = data.flowClaimStart.currentStep

                        if let dataStep = data.asFlowClaimPhoneNumberStep {

                            let phoneNumber = dataStep.phoneNumber

                            [
                                .setNewClaim(from: NewClaim(id: id)),
                                .openPhoneNumberScreen(context: contextInput, phoneNumber: phoneNumber)
                            ]
                            .forEach { element in
                                callback(.value(element))
                            }

                        } else if let dataStep = data.asFlowClaimDateOfOccurrenceStep {

                        } else if let dataStep = data.asFlowClaimAudioRecordingStep {

                        } else if let dataStep = data.asFlowClaimLocationStep {

                        } else if let dataStep = data.asFlowClaimFailedStep {

                        } else if let dataStep = data.asFlowClaimSuccessStep {

                        }
                    }
                return NilDisposer()
            }

        case let .claimNextPhoneNumber(phoneNumberInput, contextInput):

            var phoneNumber = OctopusGraphQL.FlowClaimPhoneNumberInput(phoneNumber: phoneNumberInput)

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.ClaimsFlowPhoneNumberMutation(
                            input: phoneNumber,
                            context: contextInput
                        )
                    )
                    .onValue { data in

                        let context = data.flowClaimPhoneNumberNext.context
                        let data = data.flowClaimPhoneNumberNext.currentStep

                        if let dataStep = data.asFlowClaimDateOfOccurrenceStep {

                            [
                                .openDateOfOccurrenceScreen(
                                    context: context
                                )
                            ]
                            .forEach { element in
                                callback(.value(element))
                            }

                        } else if let dataStep = data.asFlowClaimFailedStep {

                        } else if let dataStep = data.asFlowClaimDateOfOccurrencePlusLocationStep {

                            let possibleLocations = dataStep.locationStep.options

                            var dispValues: [NewClaimsInfo] = []

                            for element in possibleLocations {
                                let list = NewClaimsInfo(displayValue: element.displayName, value: element.value)
                                dispValues.append(list)
                            }

                            [
                                .setListOfLocations(displayValues: dispValues),
                                .openDateOfOccurrenceScreen(
                                    context: context
                                ),
                            ]
                            .forEach { element in
                                callback(.value(element))
                            }
                        } else {

                        }
                    }
                    .onError { error in
                        print(error)
                    }
                return NilDisposer()

            }
        case let .claimNextDateOfOccurrence(dateOfOccurrence, contextInput):

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: dateOfOccurrence)

            var dateOfOccurrenceInput = OctopusGraphQL.FlowClaimDateOfOccurrenceInput(dateOfOccurrence: dateString)

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.ClaimsFlowDateOfOccurrenceMutation(
                            input: dateOfOccurrenceInput,
                            context: contextInput
                        )
                    )
                    .onValue { data in

                        let context = data.flowClaimDateOfOccurrenceNext.context

                        [
                            .setNewDate(dateOfOccurrence: dateString)
                        ]
                        .forEach { element in
                            callback(.value(element))
                        }

                        let data = data.flowClaimDateOfOccurrenceNext.currentStep

                        if let dataStep = data.asFlowClaimAudioRecordingStep {

                        } else if let dataStep = data.asFlowClaimFailedStep {

                        } else if let dataStep = data.asFlowClaimLocationStep {

                        } else {

                        }
                    }
                    .onError { error in
                        print(error)
                    }

                return NilDisposer()

            }

        case let .claimNextLocation(displayValue, value, contextInput):

            let locationInput = OctopusGraphQL.FlowClaimLocationInput(location: value)

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.ClaimsFlowLocationMutation(input: locationInput, context: contextInput)
                    )
                    .onValue { data in

                        let context = data.flowClaimLocationNext.context

                        [
                            .setNewLocation(location: NewClaimsInfo(displayValue: displayValue, value: value))
                        ]
                        .forEach { element in
                            callback(.value(element))
                        }

                        let data = data.flowClaimLocationNext.currentStep

                        if let dataStep = data.asFlowClaimSingleItemStep {

                        } else if let dataStep = data.asFlowClaimAudioRecordingStep {

                        }
                    }
                return NilDisposer()
            }

        case let .claimNextDateOfOccurrenceAndLocation(contextInput):

            let location = state.newClaim.location?.value
            let date = state.newClaim.dateOfOccurrence

            let dateAndLocationInput = OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationInput(
                dateOfOccurrence: date,
                location: location
            )

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.ClaimsFlowDateOfOccurrencePlusLocationMutation(
                            input: dateAndLocationInput,
                            context: contextInput
                        )
                    )
                    .onValue { data in

                        let context = data.flowClaimDateOfOccurrencePlusLocationNext.context
                        let data = data.flowClaimDateOfOccurrencePlusLocationNext.currentStep

                        if let data = data.asFlowClaimAudioRecordingStep {

                            [
                                .openAudioRecordingScreen(
                                    context: context
                                )
                            ]
                            .forEach { element in
                                callback(.value(element))
                            }

                        } else if let dataStep = data.asFlowClaimSingleItemStep {

                        } else if let dataStep = data.asFlowClaimFailedStep {

                        } else if let dataStep = data.asFlowClaimSingleItemStep {

                        } else if let dataStep = data.asFlowClaimSuccessStep {

                        } else if let dataStep = data.asFlowClaimPhoneNumberStep {

                            [
                                .openAudioRecordingScreen(
                                    context: context
                                )
                            ]
                            .forEach { element in
                                callback(.value(element))
                            }
                        }

                    }
                    .onError { error in

                    }
                return NilDisposer()

            }

        case let .claimNextAudioRecording(audioURL, contextInput):
            return FiniteSignal { callback in
                do {
                    let data = try Data(contentsOf: audioURL).base64EncodedData()
                    let name = audioURL.lastPathComponent
                    let uploadFile = UploadFile(data: data, name: name, mimeType: "audio/m4a")
                    try self.fileUploaderClient.upload(flowId: self.state.newClaim.id, file: uploadFile).onValue({ responseModel in
                        let audioInput = OctopusGraphQL.FlowClaimAudioRecordingInput(audioUrl: responseModel.audioUrl)
                        self.octopus.client
                            .perform(
                                mutation: OctopusGraphQL.ClaimsFlowAudioRecordingMutation(
                                    input: audioInput,
                                    context: contextInput
                                )
                            )
                            .onValue { data in

                                let context = data.flowClaimAudioRecordingNext.context
                                let data = data.flowClaimAudioRecordingNext.currentStep

                                if let dataStep = data.asFlowClaimSuccessStep {

                                    [
                                        .openSuccessScreen(
                                            context: context
                                        )
                                    ]
                                    .forEach { element in
                                        callback(.value(element))
                                    }

                                } else if let dataStep = data.asFlowClaimFailedStep {

                                } else if let dataStep = data.asFlowClaimSingleItemStep {

                                    let damages = dataStep.availableItemProblems
                                    var dispValuesDamages: [NewClaimsInfo] = []

                                    for element in damages ?? [] {
                                        let list = NewClaimsInfo(displayValue: element.displayName, value: "")  //?
                                        dispValuesDamages.append(list)
                                    }

                                    let models = dataStep.availableItemModels
                                    var dispValuesModels: [Model] = []

                                    for element in models ?? [] {
                                        let list = Model(
                                            displayName: element.displayName,
                                            itemBrandId: element.itemBrandId,
                                            itemModelId: element.itemModelId,
                                            itemTypeID: element.itemTypeId
                                        )
                                        dispValuesModels.append(list)
                                    }

                                    let brands = dataStep.availableItemBrands
                                    var dispValuesBrands: [Brand] = []

                                    for element in brands ?? [] {
                                        let list = Brand(displayName: element.displayName, itemBrandId: element.itemBrandId)
                                        dispValuesBrands.append(list)
                                    }

                                    [
                                        .setSingleItemLists(
                                            brands: dispValuesBrands,
                                            models: dispValuesModels,
                                            damages: dispValuesDamages
                                        ),
                                        .openSingleItemScreen(
                                            context: context
                                        ),
                                    ]
                                    .forEach { element in
                                        callback(.value(element))
                                    }
                                }
                            }
                    }).onError({ error in
                        
                    })
                }catch let error {
                  _ = error
                }

                return NilDisposer()
            }

        case let .claimNextSingleItem(contextInput, purchasePrice):

            let itemBrandIdInput = state.newClaim.chosenModel?.itemBrandId ?? ""
            let itemModelInput = state.newClaim.chosenModel?.displayName ?? ""
            let itemProblemsInput = state.newClaim.chosenDamages
            let purchaseDate = state.newClaim.dateOfPurchase

            var problemsToString: [String] = []

            for element in itemProblemsInput ?? [] {
                problemsToString.append(element.displayValue)
            }

            let flowClaimItemBrandInput = OctopusGraphQL.FlowClaimItemBrandInput(
                itemTypeId: "",
                itemBrandId: itemBrandIdInput
            )
            let flowClaimItemModelInput = OctopusGraphQL.FlowClaimItemModelInput(itemModelId: itemModelInput)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: purchaseDate ?? Date())

            let singleItemInput = OctopusGraphQL.FlowClaimSingleItemInput(
                purchasePrice: purchasePrice,
                purchaseDate: dateString,
                itemProblemIds: problemsToString,
                itemBrandInput: flowClaimItemBrandInput,
                itemModelInput: flowClaimItemModelInput
                    //                customName: Optional<String?>
            )

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.ClaimsFlowSingleItemMutation(
                            input: singleItemInput,
                            context: contextInput
                        )
                    )
                    .onValue { data in

                        let data = data.flowClaimSingleItemNext.currentStep

                        [
                            .setPurchasePrice(
                                priceOfPurchase: purchasePrice
                            )
                        ]
                        .forEach { element in
                            callback(.value(element))
                        }

                        if let dataStep = data.asFlowClaimFailedStep {

                        }

                    }
                    .onError { error in

                        print(error)

                    }

                return NilDisposer()
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
        case let .setNewClaim(clame):
            newState.newClaim = clame
        case let .setNewLocation(location):
            let dateOfOccurrence = newState.newClaim.dateOfOccurrence
            newState.newClaim.dateOfOccurrence = dateOfOccurrence
            newState.newClaim.location = location

        case let .setNewDate(dateOfOccurrence):
            let location = newState.newClaim.location
            newState.newClaim.location = location
            newState.newClaim.dateOfOccurrence = dateOfOccurrence

        case let .setListOfLocations(locations):
            newState.newClaim.location = nil
            newState.newClaim.dateOfOccurrence = nil
            newState.newClaim.chosenModel = nil
            newState.newClaim.chosenBrand = nil
            newState.newClaim.chosenDamages = nil
            newState.newClaim.dateOfPurchase = nil
            newState.newClaim.priceOfPurchase = nil
            newState.newClaim.listOfLocation = locations

        case let .setSingleItemLists(brands, models, damages):
            newState.newClaim.listOfDamage = damages
            newState.newClaim.listOfBrands = brands
            newState.newClaim.listOfModels = models

        case let .setSingleItemDamage(damages):
            newState.newClaim.chosenDamages = damages

        case let .setSingleItemModel(model):
            newState.newClaim.chosenModel = model

        case let .setPurchasePrice(priceOfPurchase):
            newState.newClaim.priceOfPurchase = priceOfPurchase

        case let .setSingleItemPurchaseDate(purchaseDate):
            newState.newClaim.dateOfPurchase = purchaseDate

        case let .setSingleItemBrand(brand):
            newState.newClaim.chosenModel = nil
            newState.newClaim.chosenBrand = brand

            let modelList = newState.newClaim.listOfModels
            var filteredModelList: [Model] = []

            for model in modelList ?? [] {
                if model.itemBrandId == brand.itemBrandId {
                    filteredModelList.append(model)
                }
            }

            newState.newClaim.filteredListOfModels = filteredModelList

        default:
            break
        }

        return newState
    }
}
