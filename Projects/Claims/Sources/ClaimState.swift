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
    var newClaim: NewClaim = .init(id: "", context: "")
    var loadingStates: [String: LoadingState<String>] = [:]
    var entryPointCommonClaims: LoadingWrapper<[ClaimEntryPointResponseModel], String> = .loading
    public init() {}

    private enum CodingKeys: String, CodingKey {
        case claims, commonClaims, newClaim
    }

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

public enum LoadingState<T>: Codable & Equatable where T: Codable & Equatable {
    case loading
    case error(error: T)
}

extension ClaimsAction: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .submitAudioRecording:
            hasher.combine("submitAudioRecording")
        default:
            hasher.combine("\(try! JSONEncoder().encode(self))")
        }
    }
}

public enum ClaimsAction: ActionProtocol {
    case openFreeTextChat
    case submitNewClaim(from: ClaimsOrigin)
    case fetchClaims
    case setClaims(claims: [Claim])
    case fetchCommonClaims
    case setCommonClaims(commonClaims: [CommonClaim])
    case fetchCommonClaimsForSelection
    case setCommonClaimsForSelection(LoadingWrapper<[ClaimEntryPointResponseModel], String>)
    case commonClaimOriginSelected(commonClaim: ClaimsOrigin)
    case openCommonClaimDetail(commonClaim: CommonClaim)
    case openHowClaimsWork
    case openClaimDetails(claim: Claim)
    case odysseyRedirect(url: String)

    case dissmissNewClaimFlow

    case openPhoneNumberScreen(phoneNumber: String)
    case submitClaimPhoneNumber(phoneNumberInput: String)

    case openDateOfOccurrenceScreen(maxDate: Date)
    case openLocationPicker
    case openDatePicker

    case submitClaimDateOfOccurrence(dateOfOccurrence: Date)
    case submitClaimLocation(displayValue: String, value: String)
    case submitOccuranceAndLocation
    case submitAudioRecording(audioURL: URL)
    case submitSingleItem(purchasePrice: Double)
    case submitDamage(damage: [Damage])
    case claimNextDamage(damages: Damage)
    case submitModel(model: Model)
    case submitBrand(brand: Brand)
    case submitSummary
    case submitSingleItemCheckout

    case openSuccessScreen
    case openSingleItemScreen(maxDate: Date)
    case openSummaryScreen
    case openSummaryEditScreen
    case openDamagePickerScreen
    case openModelPicker
    case openBrandPicker
    case openCheckoutNoRepairScreen
    case openCheckoutTransferringScreen
    case openCheckoutTransferringDoneScreen
    case openAudioRecordingScreen(questions: [String])

    case startClaim(from: String)
    case setNewClaim(from: NewClaim)
    case claimNextPhoneNumber(phoneNumber: String)
    case claimNextDateOfOccurrence(dateOfOccurrence: Date)
    case claimNextLocation(displayName: String, displayValue: String)
    case claimNextDateOfOccurrenceAndLocation
    case claimNextSingleItem(purchasePrice: Double)
    case claimNextSummary
    case claimNextSingleItemCheckout

    case setNewLocation(location: Location?)
    case setNewDate(dateOfOccurrence: String?)
    case setListOfLocations(displayValues: [Location])
    case setPurchasePrice(priceOfPurchase: Amount)
    case setSingleItemLists(brands: [Brand], models: [Model], damages: [Damage])
    case setSingleItemModel(modelName: Model)
    case setSingleItemPriceOfPurchase(purchasePrice: Double)
    case setSingleItemDamage(damages: [Damage])
    case setSingleItemPurchaseDate(purchaseDate: Date)
    case setSingleItemBrand(brand: Brand)
    case setLoadingState(action: String, state: LoadingState<String>?)
    case setPayoutAmountDeductibleDepreciation(payoutAmount: Amount, deductible: Amount, depreciation: Amount)
    case setPrefferedCurrency(currency: String)
    case setNewClaimContext(context: String)
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
    
    public var id: String {
        switch self {
        case .generic:
            return ""
        case .commonClaims(let id):
            return id
        }
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
        let actionValue = "\(action.hashValue)"
        let newClaimContext = state.newClaim.context
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
        case let .startClaim(id):
            self.send(.setLoadingState(action: actionValue, state: .loading))
            let startInput = OctopusGraphQL.FlowClaimStartInput(entrypointId: id)
            return FiniteSignal { callback in
                var disposeBag = DisposeBag()
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.FlowClaimStartMutation(input: startInput)
                    )
                    .onValue { data in
                        data.handleActions(for: action, and: callback)
                    }
                    .onError { error in
                        callback(
                            .value(
                                .setLoadingState(action: actionValue, state: .error(error: error.localizedDescription))
                            )
                        )
                    }
                return NilDisposer()
            }
        case let .claimNextPhoneNumber(phoneNumberInput):
            self.send(.setLoadingState(action: actionValue, state: .loading))
            var phoneNumber = OctopusGraphQL.FlowClaimPhoneNumberInput(phoneNumber: phoneNumberInput)
            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.ClaimsFlowPhoneNumberMutation(
                            input: phoneNumber,
                            context: newClaimContext
                        )
                    )
                    .onValue { data in
                        var actions = [ClaimsAction]()
                        let context = data.flowClaimPhoneNumberNext.context
                        let data = data.flowClaimPhoneNumberNext.currentStep
                        actions.append(.setNewClaimContext(context: context))
                        if let dataStep = data.asFlowClaimDateOfOccurrenceStep {

                            let dateOfOccurrenceMaxDate = dataStep.maxDate
                            let maxDateToDate = self.state.newClaim.formatStringToDate(
                                dateString: dateOfOccurrenceMaxDate
                            )

                            actions.append(
                                .openDateOfOccurrenceScreen(maxDate: maxDateToDate)
                            )
                        } else if let dataStep = data.asFlowClaimFailedStep {

                        } else if let dataStep = data.asFlowClaimDateOfOccurrencePlusLocationStep {
                            let dateOfOccurrenceStep = dataStep.dateOfOccurrenceStep.dateOfOccurrence
                            let dateOfOccurrenceMaxDate = dataStep.dateOfOccurrenceStep.maxDate
                            let maxDateToDate = self.state.newClaim.formatStringToDate(
                                dateString: dateOfOccurrenceMaxDate
                            )
                            let locationStep = dataStep.locationStep.location
                            let possibleLocations = dataStep.locationStep.options

                            var dispValues: [Location] = []

                            for element in possibleLocations {
                                let list = Location(displayValue: element.displayName, value: element.value)
                                dispValues.append(list)
                            }
                            actions.append(contentsOf: [
                                .setListOfLocations(displayValues: dispValues),
                                .openDateOfOccurrenceScreen(maxDate: maxDateToDate),
                            ])

                        } else {

                        }
                        actions.append(.setLoadingState(action: actionValue, state: nil))
                        actions.forEach { element in
                            callback(.value(element))
                        }
                    }
                    .onError { error in
                        callback(
                            .value(
                                .setLoadingState(action: actionValue, state: .error(error: error.localizedDescription))
                            )
                        )
                    }
                return NilDisposer()
                
            }
        case let .claimNextDateOfOccurrence(dateOfOccurrence):

            let dateString = state.newClaim.formatDateToString(date: dateOfOccurrence)
            var dateOfOccurrenceInput = OctopusGraphQL.FlowClaimDateOfOccurrenceInput(dateOfOccurrence: dateString)

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.ClaimsFlowDateOfOccurrenceMutation(
                            input: dateOfOccurrenceInput,
                            context: newClaimContext
                        )
                    )
                    .onValue { data in
                        var actions = [ClaimsAction]()
                        actions.append(.setNewClaimContext(context: data.flowClaimDateOfOccurrenceNext.context))
                        actions.append(.setNewDate(dateOfOccurrence: dateString))
                        actions.forEach { element in
                            callback(.value(element))
                        }
                    }
                    .onError { error in
                        print(error)
                    }

                return NilDisposer()

            }

        case let .claimNextLocation(displayValue, value):

            let locationInput = OctopusGraphQL.FlowClaimLocationInput(location: value)

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.ClaimsFlowLocationMutation(input: locationInput, context: newClaimContext)
                    )
                    .onValue { data in

                        var actions = [ClaimsAction]()
                        actions.append(.setNewClaimContext(context: data.flowClaimLocationNext.context))
                        actions.append(.setNewLocation(location: Location(displayValue: displayValue, value: value)))

                        actions.forEach { element in
                            callback(.value(element))
                        }
                    }
                return NilDisposer()
            }

        case .claimNextDateOfOccurrenceAndLocation:
            self.send(.setLoadingState(action: actionValue, state: .loading))
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
                            context: newClaimContext
                        )
                    )
                    .onValue { data in
                        var actions = [ClaimsAction]()
                        actions.append(.setNewClaimContext(context: data.flowClaimDateOfOccurrencePlusLocationNext.context))

                        let data = data.flowClaimDateOfOccurrencePlusLocationNext.currentStep

                        if let data = data.asFlowClaimAudioRecordingStep {
                            let questions = data.questions
                            actions.append(.openAudioRecordingScreen(questions: questions))
                        } else if let dataStep = data.asFlowClaimSingleItemStep {

                        } else if let dataStep = data.asFlowClaimFailedStep {
                        } else if let dataStep = data.asFlowClaimSingleItemStep {

                        } else if let dataStep = data.asFlowClaimSuccessStep {

                        } else if let dataStep = data.asFlowClaimPhoneNumberStep {
                        }
                        actions.append(.setLoadingState(action: actionValue, state: nil))
                        actions.forEach({ callback(.value($0)) })
                    }
                    .onError { error in
                        callback(
                            .value(
                                .setLoadingState(action: actionValue, state: .error(error: error.localizedDescription))
                            )
                        )
                    }
                return NilDisposer()

            }

        case let .submitAudioRecording(audioURL):
            self.send(.setLoadingState(action: actionValue, state: .loading))
            return FiniteSignal { callback in
                do {
                    let data = try Data(contentsOf: audioURL).base64EncodedData()
                    let name = audioURL.lastPathComponent
                    let uploadFile = UploadFile(data: data, name: name, mimeType: "audio/m4a")
                    try self.fileUploaderClient.upload(flowId: self.state.newClaim.id, file: uploadFile)
                        .onValue({ responseModel in
                            let audioInput = OctopusGraphQL.FlowClaimAudioRecordingInput(
                                audioUrl: responseModel.audioUrl
                            )
                            self.octopus.client
                                .perform(
                                    mutation: OctopusGraphQL.ClaimsFlowAudioRecordingMutation(
                                        input: audioInput,
                                        context: newClaimContext
                                    )
                                )
                                .onValue { data in

                                    let context = data.flowClaimAudioRecordingNext.context
                                    var actions = [ClaimsAction]()
                                    actions.append(.setNewClaimContext(context: context))
                                    let data = data.flowClaimAudioRecordingNext.currentStep
                                    if let dataStep = data.asFlowClaimSuccessStep {
                                        actions.append(.openSuccessScreen)

                                    } else if let dataStep = data.asFlowClaimSingleItemStep {

                                        let prefferedCurrency = dataStep.preferredCurrency  //for purchasePrice

                                        let selectedProblems = dataStep.selectedItemProblems
                                        let damages = dataStep.availableItemProblems
                                        let models = dataStep.availableItemModels
                                        let brands = dataStep.availableItemBrands

                                        var selectedDamages: [Damage] = []

                                        for element in selectedProblems ?? [] {
                                            selectedDamages.append(
                                                Damage(
                                                    displayName: element.displayValue,
                                                    itemProblemId: element.displayValue
                                                )
                                            )
                                        }

                                        var dispValuesDamages: [Damage] = []

                                        for element in damages ?? [] {
                                            let list = Damage(
                                                displayName: element.displayName,
                                                itemProblemId: element.itemProblemId
                                            )
                                            dispValuesDamages.append(list)
                                        }

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

                                        var dispValuesBrands: [Brand] = []

                                        for element in brands ?? [] {
                                            let list = Brand(
                                                displayName: element.displayName,
                                                itemBrandId: element.itemBrandId
                                            )
                                            dispValuesBrands.append(list)
                                        }

                                        [
                                            .setSingleItemDamage(damages: selectedDamages),
                                            .setSingleItemLists(
                                                brands: dispValuesBrands,
                                                models: dispValuesModels,
                                                damages: dispValuesDamages
                                            ),
                                            .openSingleItemScreen(
                                                maxDate: Date()
                                            ),
                                        ]
                                        .forEach { element in
                                            callback(.value(element))
                                        }
                                    }
                                    actions.append(.setLoadingState(action: actionValue, state: nil))
                                    actions.forEach({ callback(.value($0)) })
                                }
                        })
                        .onError({ error in
                            callback(
                                .value(
                                    .setLoadingState(
                                        action: actionValue,
                                        state: .error(error: error.localizedDescription)
                                    )
                                )
                            )
                        })
                } catch let error {
                    callback(
                        .value(.setLoadingState(action: actionValue, state: .error(error: error.localizedDescription)))
                    )
                }

                return NilDisposer()
            }
        case let .submitDamage(damages):
            return FiniteSignal { callback in
                callback(.value(.setSingleItemDamage(damages: damages)))
                return NilDisposer()
            }

        case let .claimNextSingleItem(purchasePrice):
            self.send(.setLoadingState(action: actionValue, state: .loading))
            let singleItemInput = state.newClaim.returnSingleItemInfo(purchasePrice: purchasePrice)

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.ClaimsFlowSingleItemMutation(
                            input: singleItemInput,
                            context: newClaimContext
                        )
                    )
                    .onValue { data in

                        let context = data.flowClaimSingleItemNext.context
                        let data = data.flowClaimSingleItemNext.currentStep
                        let prefferedCurrency = data.asFlowClaimSingleItemStep?.preferredCurrency.rawValue

                        var actions = [ClaimsAction]()
                        actions.append(.setNewClaimContext(context: context))
                        actions.append(
                            .setPurchasePrice(
                                priceOfPurchase:
                                    Amount(
                                        amount: purchasePrice,
                                        currencyCode: prefferedCurrency ?? ""
                                    )
                            )
                        )
                        if let dataStep = data.asFlowClaimFailedStep {
                            let ss = ""
                        } else if let dataStep = data.asFlowClaimSummaryStep {
                            actions.append(.openSummaryScreen)
                        }
                        actions.append(.setLoadingState(action: actionValue, state: nil))
                        actions.forEach({ callback(.value($0)) })
                    }
                    .onError { error in

                        print(error)

                    }
                return NilDisposer()
            }

        case let .claimNextSummary:

            let dateOfOccurrence = state.newClaim.dateOfOccurrence
            let location = state.newClaim.location
            let summaryInput = state.newClaim.returnSummaryInformation()

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.ClaimsFlowSummaryMutation(input: summaryInput, context: newClaimContext)
                    )
                    .onValue { data in

                        let context = data.flowClaimSummaryNext.context
                        var actions = [ClaimsAction]()
                        actions.append(.setNewClaimContext(context: context))
                        
                        let data = data.flowClaimSummaryNext.currentStep
                        if let dataStep = data.asFlowClaimSuccessStep {
                            actions.append(.openSuccessScreen)
                        } else if let dataStep = data.asFlowClaimSingleItemCheckoutStep {
                            let payoutAmount = dataStep.payoutAmount
                            let deductible = dataStep.deductible
                            let depreciation = dataStep.depreciation
                            let purchasePricePriceToShow = dataStep.price

                            [
                                .setPurchasePrice(
                                    priceOfPurchase:
                                        Amount(
                                            amount: purchasePricePriceToShow.amount,
                                            currencyCode: purchasePricePriceToShow.currencyCode.rawValue
                                        )
                                ),
                                .setPayoutAmountDeductibleDepreciation(
                                    payoutAmount:
                                        Amount(
                                            amount: payoutAmount.amount,
                                            currencyCode: payoutAmount.currencyCode.rawValue
                                        ),
                                    deductible:
                                        Amount(
                                            amount: deductible.amount,
                                            currencyCode: deductible.currencyCode.rawValue
                                        ),
                                    depreciation:
                                        Amount(
                                            amount: depreciation.amount,
                                            currencyCode: depreciation.currencyCode.rawValue
                                        )
                                ),
                                .openCheckoutNoRepairScreen,
                            ]
                            .forEach { element in
                                callback(.value(element))
                            }
                        } else if let dataStep = data.asFlowClaimFailedStep {
                        }
                        
                        
                        actions.forEach { element in
                            callback(.value(element))
                        }
                    }
                    .onError { error in
                        print(error)
                    }
                return NilDisposer()
            }

        case let .claimNextSingleItemCheckout:

            let claimSingleItemCheckoutInput = state.newClaim.returnSingleItemCheckoutInfo()

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.ClaimsFlowSingleItemCheckoutMutation(
                            input: claimSingleItemCheckoutInput,
                            context: newClaimContext
                        )
                    )
                    .onValue { data in
                        
                        let context = data.flowClaimSingleItemCheckoutNext.context
                        var actions = [ClaimsAction]()
                        actions.append(.setNewClaimContext(context: context))
                        let data = data.flowClaimSingleItemCheckoutNext.currentStep

                        if let dataStep = data.asFlowClaimFailedStep {

                        } else if let dataStep = data.asFlowClaimSuccessStep {
                            actions.append(.openCheckoutTransferringScreen)
                        } else {
                            actions.append(.openCheckoutTransferringScreen)
                        }
                        
                        actions.forEach { element in
                            callback(.value(element))
                        }

                    }
                return NilDisposer()
            }
        case .fetchCommonClaimsForSelection:
            self.send(.setCommonClaimsForSelection(.loading))
            let getEntryPointsClaimsClient: GetEntryPointsClaimsClient = Dependencies.shared.resolve()
            return getEntryPointsClaimsClient.execute()
                .map({ claims in
                    return .setCommonClaimsForSelection(.success(claims))
                })
                .onError({ error in
                    self.send(.setCommonClaimsForSelection(.error(error.localizedDescription)))
                })
                .valueThenEndSignal
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
            newState.newClaim.payoutAmount = nil
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

        case let .setLoadingState(action, state):
            if let state {
                newState.loadingStates[action] = state
            } else {
                newState.loadingStates.removeValue(forKey: action)
            }
        case let .setPayoutAmountDeductibleDepreciation(payoutAmount, deductible, depreciation):
            newState.newClaim.payoutAmount = payoutAmount
            newState.newClaim.deductible = deductible
            newState.newClaim.depreciation = depreciation

        case let .setPrefferedCurrency(currency):
            newState.newClaim.prefferedCurrency = currency

        case let .setNewClaimContext(context):
            newState.newClaim.context = context
        case let .setCommonClaimsForSelection(commonClaims):
            newState.entryPointCommonClaims = commonClaims
        default:
            break
        }
        return newState
    }

}

protocol NextClaimSteps {
    func handleActions(for action: ClaimsAction, and callback: (Event<ClaimsAction>) -> Void)
}
//
extension OctopusGraphQL.FlowClaimStartMutation.Data: NextClaimSteps {
    func handleActions(for action: ClaimsAction, and callback: (Event<ClaimsAction>) -> Void) {
        let id = self.flowClaimStart.id
        let context = self.flowClaimStart.context
        let data = self.flowClaimStart.currentStep
        var actions = [ClaimsAction]()
        if let dataStep = data.asFlowClaimPhoneNumberStep {
            let phoneNumber = dataStep.phoneNumber
            actions.append(.setNewClaim(from: NewClaim(id: id, context: context)))
            actions.append(.openPhoneNumberScreen(phoneNumber: phoneNumber))
        } else if let dataStep = data.asFlowClaimDateOfOccurrenceStep {
            
        } else if let dataStep = data.asFlowClaimAudioRecordingStep {
            
        } else if let dataStep = data.asFlowClaimLocationStep {
            
        } else if let dataStep = data.asFlowClaimFailedStep {
            
        } else if let dataStep = data.asFlowClaimSuccessStep {
            
        }
        actions.append(.setLoadingState(action: "\(action.hashValue)", state: nil))
        actions.forEach { element in
            callback(.value(element))
        }
    }
}
