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
    var loadingStates: [ClaimsAction: LoadingState<String>] = [:]
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

    public func shouldShowListOfModels(for brand: Brand) -> Bool {
        return !(self.newClaim.getListOfModels(for: brand)?.isEmpty ?? true)
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

public indirect enum ClaimsAction: ActionProtocol {
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
    case submitTransferringFunds

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
    case openFailureSceen

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
    case setLoadingState(action: ClaimsAction, state: LoadingState<String>?)
    case setPayoutAmountDeductibleDepreciation(payoutAmount: Amount, deductible: Amount, depreciation: Amount)
    case setPrefferedCurrency(currency: String)
    case setNewClaimContext(context: String)
    case setMaxDateOfOccurrence(maxDate: String)
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

            self.send(.setLoadingState(action: action, state: .loading))
            let startInput = OctopusGraphQL.FlowClaimStartInput(entrypointId: id)
            let mutation = OctopusGraphQL.FlowClaimStartMutation(input: startInput)
            return mutation.getFuture(action: action, store: self)
        case let .claimNextPhoneNumber(phoneNumberInput):
            self.send(.setLoadingState(action: action, state: .loading))
            let phoneNumber = OctopusGraphQL.FlowClaimPhoneNumberInput(phoneNumber: phoneNumberInput)
            let mutation = OctopusGraphQL.ClaimsFlowPhoneNumberMutation(input: phoneNumber, context: newClaimContext)
            return mutation.getFuture(action: action, store: self)
        case let .claimNextDateOfOccurrence(dateOfOccurrence):
            let dateString = state.newClaim.formatDateToString(date: dateOfOccurrence)
            let dateOfOccurrenceInput = OctopusGraphQL.FlowClaimDateOfOccurrenceInput(dateOfOccurrence: dateString)
            let mutation = OctopusGraphQL.ClaimsFlowDateOfOccurrenceMutation(
                input: dateOfOccurrenceInput,
                context: newClaimContext
            )  //ClaimsFlowDateOfOccurrenceMutation(
            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: mutation
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
                        mutation: OctopusGraphQL.ClaimsFlowLocationMutation(
                            input: locationInput,
                            context: newClaimContext
                        )
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
            self.send(.setLoadingState(action: action, state: .loading))
            let location = state.newClaim.location?.value
            let date = state.newClaim.dateOfOccurrence

            let dateAndLocationInput = OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationInput(
                dateOfOccurrence: date,
                location: location
            )
            let mutation = OctopusGraphQL.ClaimsFlowDateOfOccurrencePlusLocationMutation(
                input: dateAndLocationInput,
                context: newClaimContext
            )
            return mutation.getFuture(action: action, store: self)

        case let .submitAudioRecording(audioURL):
            self.send(.setLoadingState(action: action, state: .loading))
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                do {
                    let data = try Data(contentsOf: audioURL)
                    let name = audioURL.lastPathComponent
                    let uploadFile = UploadFile(data: data, name: name, mimeType: "audio/x-m4a")
                    disposeBag += try self.fileUploaderClient.upload(flowId: self.state.newClaim.id, file: uploadFile)
                        .onValue({ responseModel in
                            //todo
                            let audioInput = OctopusGraphQL.FlowClaimAudioRecordingInput(
                                audioUrl: responseModel.audioUrl
                            )
                            let mutation = OctopusGraphQL.ClaimsFlowAudioRecordingMutation(
                                input: audioInput,
                                context: newClaimContext
                            )
                            disposeBag += mutation.getFuture(action: action, store: self)?
                                .onValue({ action in
                                    callback(.value(action))
                                })
                        })
                        .onError({ error in
                            callback(
                                .value(
                                    .setLoadingState(
                                        action: action,
                                        state: .error(error: error.localizedDescription)
                                    )
                                )
                            )
                        })
                        .disposable
                } catch let error {
                    callback(
                        .value(.setLoadingState(action: action, state: .error(error: error.localizedDescription)))
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
            self.send(.setLoadingState(action: action, state: .loading))
            let singleItemInput = state.newClaim.returnSingleItemInfo(purchasePrice: purchasePrice)
            let mutation = OctopusGraphQL.ClaimsFlowSingleItemMutation(
                context: state.newClaim.context,
                input: singleItemInput
            )
            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: mutation
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
                        } else if let dataStep = data.asFlowClaimSummaryStep {

                            actions.append(.openSummaryScreen)
                        }
                        actions.append(.setLoadingState(action: action, state: nil))
                        actions.forEach({ callback(.value($0)) })
                    }
                    .onError { error in
                        callback(
                            .value(.setLoadingState(action: action, state: .error(error: error.localizedDescription)))
                        )
                        print(error)

                    }
                return NilDisposer()
            }

        case .claimNextSummary:
            let dateOfOccurrence = state.newClaim.dateOfOccurrence
            let location = state.newClaim.location
            let summaryInput = state.newClaim.returnSummaryInformation()
            let mutation = OctopusGraphQL.ClaimsFlowSummaryMutation(
                input: summaryInput,
                context: newClaimContext
            )
            return mutation.getFuture(action: action, store: self)
        case .claimNextSingleItemCheckout:
            let claimSingleItemCheckoutInput = state.newClaim.returnSingleItemCheckoutInfo()
            let mutation = OctopusGraphQL.ClaimsFlowSingleItemCheckoutMutation(
                input: claimSingleItemCheckoutInput,
                context: newClaimContext
            )
            return mutation.getFuture(action: action, store: self)
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
            //<<<<<<< Updated upstream
            newState.newClaim.filteredListOfModels = newState.newClaim.getListOfModels(for: brand)
        //=======
        //
        //            let modelList = newState.newClaim.listOfModels
        //            var filteredModelList: [Model] = []
        //
        //            for model in modelList ?? [] {
        //                if model.itemBrandId == brand.itemBrandId {
        //                    filteredModelList.append(model)
        //                }
        //            }
        //            newState.newClaim.filteredListOfModels = filteredModelList
        //
        //>>>>>>> Stashed changes
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

        case let .setMaxDateOfOccurrence(maxDate):
            newState.newClaim.maxDateOfoccurrance = maxDate

        default:
            break
        }
        return newState
    }
}

protocol NextClaimSteps {
    func handleActions(for action: ClaimsAction, and callback: (Event<ClaimsAction>) -> Void, and store: ClaimsStore)
}

extension OctopusGraphQL.FlowClaimStartMutation.Data: NextClaimSteps {
    func handleActions(for action: ClaimsAction, and callback: (Event<ClaimsAction>) -> Void, and store: ClaimsStore) {

        let id = self.flowClaimStart.id
        let context = self.flowClaimStart.context
        let data = self.flowClaimStart.currentStep
        var actions = [ClaimsAction]()
        actions.append(.setNewClaim(from: NewClaim(id: id, context: context)))

        switch data.__typename {

        case "FlowClaimPhoneNumberStep":
            let phoneNumber = data.asFlowClaimPhoneNumberStep?.phoneNumber ?? ""
            actions.append(.openPhoneNumberScreen(phoneNumber: phoneNumber))

        case "FlowClaimAudioRecordingStep":
            let questions = data.asFlowClaimAudioRecordingStep?.questions ?? [""]
            actions.append(.openAudioRecordingScreen(questions: questions))

        case "FlowClaimSingleItemStep":
            let prefferedCurrency = data.asFlowClaimSingleItemStep?.preferredCurrency
            let selectedProblems = data.asFlowClaimSingleItemStep?.selectedItemProblems
            let damages = data.asFlowClaimSingleItemStep?.availableItemProblems
            let models = data.asFlowClaimSingleItemStep?.availableItemModels
            let brands = data.asFlowClaimSingleItemStep?.availableItemBrands

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

            actions.append(contentsOf: [
                .setPrefferedCurrency(currency: prefferedCurrency?.rawValue ?? ""),
                .setSingleItemLists(
                    brands: dispValuesBrands,
                    models: dispValuesModels,
                    damages: dispValuesDamages
                ),
                .openSingleItemScreen(
                    maxDate: Date()
                ),
            ])

        case "FlowClaimSingleItemCheckoutStep":
            let payoutAmount = data.asFlowClaimSingleItemCheckoutStep?.payoutAmount
            let deductible = data.asFlowClaimSingleItemCheckoutStep?.deductible
            let depreciation = data.asFlowClaimSingleItemCheckoutStep?.depreciation
            let purchasePricePriceToShow = data.asFlowClaimSingleItemCheckoutStep?.price

            actions.append(contentsOf: [
                .setPurchasePrice(
                    priceOfPurchase:
                        Amount(
                            amount: purchasePricePriceToShow?.amount ?? 0,
                            currencyCode: purchasePricePriceToShow?.currencyCode.rawValue ?? ""
                        )
                ),
                .setPayoutAmountDeductibleDepreciation(
                    payoutAmount:
                        Amount(
                            amount: payoutAmount?.amount ?? 0,
                            currencyCode: payoutAmount?.currencyCode.rawValue ?? ""
                        ),
                    deductible:
                        Amount(
                            amount: deductible?.amount ?? 0,
                            currencyCode: deductible?.currencyCode.rawValue ?? ""
                        ),
                    depreciation:
                        Amount(
                            amount: depreciation?.amount ?? 0,
                            currencyCode: depreciation?.currencyCode.rawValue ?? ""
                        )
                ),
                .openCheckoutNoRepairScreen,
            ])

        case "FlowClaimLocationStep":
            let dateOfOccurrenceMaxDate = store.state.newClaim.maxDateOfoccurrance ?? ""
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate
            )

            actions.append(
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate)
            )

        case "FlowClaimDateOfOccurrenceStep":
            let dateOfOccurrenceMaxDate = data.asFlowClaimDateOfOccurrenceStep?.maxDate
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
            )

            actions.append(
                .setMaxDateOfOccurrence(
                    maxDate: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
                )
            )
            actions.append(
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate)
            )

        case "FlowClaimSummaryStep":
            actions.append(.openSummaryScreen)

        case "FlowClaimDateOfOccurrencePlusLocationStep":
            let dateOfOccurrenceStep = data.asFlowClaimDateOfOccurrencePlusLocationStep?.dateOfOccurrenceStep
                .dateOfOccurrence
            let dateOfOccurrenceMaxDate = data.asFlowClaimDateOfOccurrencePlusLocationStep?.dateOfOccurrenceStep.maxDate
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
            )
            let locationStep = data.asFlowClaimDateOfOccurrencePlusLocationStep?.locationStep.location
            let possibleLocations = data.asFlowClaimDateOfOccurrencePlusLocationStep?.locationStep.options ?? []

            var dispValues: [Location] = []

            for element in possibleLocations {
                let list = Location(displayValue: element.displayName, value: element.value)
                dispValues.append(list)
            }
            actions.append(contentsOf: [
                .setMaxDateOfOccurrence(
                    maxDate: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
                ),
                .setListOfLocations(displayValues: dispValues),
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate),
            ])

        case "FlowClaimFailedStep":
            actions.append(
                .openFailureSceen
            )

        case "FlowClaimSuccessStep":
            actions.append(.openSuccessScreen)

        default:
            break
        }

        actions.append(.setLoadingState(action: action, state: nil))
        actions.forEach({ callback(.value($0)) })
    }
}

extension OctopusGraphQL.ClaimsFlowPhoneNumberMutation.Data: NextClaimSteps {
    func handleActions(for action: ClaimsAction, and callback: (Event<ClaimsAction>) -> Void, and store: ClaimsStore) {
        var actions = [ClaimsAction]()
        let context = self.flowClaimPhoneNumberNext.context
        let data = self.flowClaimPhoneNumberNext.currentStep
        actions.append(.setNewClaimContext(context: context))

        switch data.__typename {

        case "FlowClaimPhoneNumberStep":
            let phoneNumber = data.asFlowClaimPhoneNumberStep?.phoneNumber ?? ""
            actions.append(.openPhoneNumberScreen(phoneNumber: phoneNumber))

        case "FlowClaimAudioRecordingStep":
            let questions = data.asFlowClaimAudioRecordingStep?.questions ?? [""]
            actions.append(.openAudioRecordingScreen(questions: questions))

        case "FlowClaimSingleItemStep":
            let prefferedCurrency = data.asFlowClaimSingleItemStep?.preferredCurrency
            let selectedProblems = data.asFlowClaimSingleItemStep?.selectedItemProblems
            let damages = data.asFlowClaimSingleItemStep?.availableItemProblems
            let models = data.asFlowClaimSingleItemStep?.availableItemModels
            let brands = data.asFlowClaimSingleItemStep?.availableItemBrands

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

            actions.append(contentsOf: [
                .setPrefferedCurrency(currency: prefferedCurrency?.rawValue ?? ""),
                .setSingleItemLists(
                    brands: dispValuesBrands,
                    models: dispValuesModels,
                    damages: dispValuesDamages
                ),
                .openSingleItemScreen(
                    maxDate: Date()
                ),
            ])

        case "FlowClaimSingleItemCheckoutStep":
            let payoutAmount = data.asFlowClaimSingleItemCheckoutStep?.payoutAmount
            let deductible = data.asFlowClaimSingleItemCheckoutStep?.deductible
            let depreciation = data.asFlowClaimSingleItemCheckoutStep?.depreciation
            let purchasePricePriceToShow = data.asFlowClaimSingleItemCheckoutStep?.price

            actions.append(contentsOf: [
                .setPurchasePrice(
                    priceOfPurchase:
                        Amount(
                            amount: purchasePricePriceToShow?.amount ?? 0,
                            currencyCode: purchasePricePriceToShow?.currencyCode.rawValue ?? ""
                        )
                ),
                .setPayoutAmountDeductibleDepreciation(
                    payoutAmount:
                        Amount(
                            amount: payoutAmount?.amount ?? 0,
                            currencyCode: payoutAmount?.currencyCode.rawValue ?? ""
                        ),
                    deductible:
                        Amount(
                            amount: deductible?.amount ?? 0,
                            currencyCode: deductible?.currencyCode.rawValue ?? ""
                        ),
                    depreciation:
                        Amount(
                            amount: depreciation?.amount ?? 0,
                            currencyCode: depreciation?.currencyCode.rawValue ?? ""
                        )
                ),
                .openCheckoutNoRepairScreen,
            ])

        case "FlowClaimLocationStep":
            let dateOfOccurrenceMaxDate = store.state.newClaim.maxDateOfoccurrance ?? ""
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate
            )

            actions.append(
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate)
            )

        case "FlowClaimDateOfOccurrenceStep":
            let dateOfOccurrenceMaxDate = data.asFlowClaimDateOfOccurrenceStep?.maxDate
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
            )

            actions.append(
                .setMaxDateOfOccurrence(
                    maxDate: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
                )
            )
            actions.append(
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate)
            )

        case "FlowClaimSummaryStep":
            actions.append(.openSummaryScreen)

        case "FlowClaimDateOfOccurrencePlusLocationStep":
            let dateOfOccurrenceStep = data.asFlowClaimDateOfOccurrencePlusLocationStep?.dateOfOccurrenceStep
                .dateOfOccurrence
            let dateOfOccurrenceMaxDate = data.asFlowClaimDateOfOccurrencePlusLocationStep?.dateOfOccurrenceStep.maxDate
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
            )
            let locationStep = data.asFlowClaimDateOfOccurrencePlusLocationStep?.locationStep.location
            let possibleLocations = data.asFlowClaimDateOfOccurrencePlusLocationStep?.locationStep.options ?? []

            var dispValues: [Location] = []

            for element in possibleLocations {
                let list = Location(displayValue: element.displayName, value: element.value)
                dispValues.append(list)
            }
            actions.append(contentsOf: [
                .setMaxDateOfOccurrence(
                    maxDate: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
                ),
                .setListOfLocations(displayValues: dispValues),
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate),
            ])

        case "FlowClaimFailedStep":
            actions.append(
                .openFailureSceen
            )

        case "FlowClaimSuccessStep":
            actions.append(.openSuccessScreen)

        default:
            break
        }

        actions.append(.setLoadingState(action: action, state: nil))
        actions.forEach({ callback(.value($0)) })
    }
}

extension OctopusGraphQL.ClaimsFlowDateOfOccurrencePlusLocationMutation.Data: NextClaimSteps {
    func handleActions(
        for action: ClaimsAction,
        and callback: (Flow.Event<ClaimsAction>) -> Void,
        and store: ClaimsStore
    ) {
        var actions = [ClaimsAction]()
        actions.append(
            .setNewClaimContext(context: self.flowClaimDateOfOccurrencePlusLocationNext.context)
        )

        let data = self.flowClaimDateOfOccurrencePlusLocationNext.currentStep

        switch data.__typename {

        case "FlowClaimPhoneNumberStep":
            let phoneNumber = data.asFlowClaimPhoneNumberStep?.phoneNumber ?? ""
            actions.append(.openPhoneNumberScreen(phoneNumber: phoneNumber))

        case "FlowClaimAudioRecordingStep":
            let questions = data.asFlowClaimAudioRecordingStep?.questions ?? [""]
            actions.append(.openAudioRecordingScreen(questions: questions))

        case "FlowClaimSingleItemStep":
            let prefferedCurrency = data.asFlowClaimSingleItemStep?.preferredCurrency
            let selectedProblems = data.asFlowClaimSingleItemStep?.selectedItemProblems
            let damages = data.asFlowClaimSingleItemStep?.availableItemProblems
            let models = data.asFlowClaimSingleItemStep?.availableItemModels
            let brands = data.asFlowClaimSingleItemStep?.availableItemBrands

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

            actions.append(contentsOf: [
                .setPrefferedCurrency(currency: prefferedCurrency?.rawValue ?? ""),
                .setSingleItemLists(
                    brands: dispValuesBrands,
                    models: dispValuesModels,
                    damages: dispValuesDamages
                ),
                .openSingleItemScreen(
                    maxDate: Date()
                ),
            ])

        case "FlowClaimSingleItemCheckoutStep":
            let payoutAmount = data.asFlowClaimSingleItemCheckoutStep?.payoutAmount
            let deductible = data.asFlowClaimSingleItemCheckoutStep?.deductible
            let depreciation = data.asFlowClaimSingleItemCheckoutStep?.depreciation
            let purchasePricePriceToShow = data.asFlowClaimSingleItemCheckoutStep?.price

            actions.append(contentsOf: [
                .setPurchasePrice(
                    priceOfPurchase:
                        Amount(
                            amount: purchasePricePriceToShow?.amount ?? 0,
                            currencyCode: purchasePricePriceToShow?.currencyCode.rawValue ?? ""
                        )
                ),
                .setPayoutAmountDeductibleDepreciation(
                    payoutAmount:
                        Amount(
                            amount: payoutAmount?.amount ?? 0,
                            currencyCode: payoutAmount?.currencyCode.rawValue ?? ""
                        ),
                    deductible:
                        Amount(
                            amount: deductible?.amount ?? 0,
                            currencyCode: deductible?.currencyCode.rawValue ?? ""
                        ),
                    depreciation:
                        Amount(
                            amount: depreciation?.amount ?? 0,
                            currencyCode: depreciation?.currencyCode.rawValue ?? ""
                        )
                ),
                .openCheckoutNoRepairScreen,
            ])

        case "FlowClaimLocationStep":
            let dateOfOccurrenceMaxDate = store.state.newClaim.maxDateOfoccurrance ?? ""
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate
            )

            actions.append(
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate)
            )

        case "FlowClaimDateOfOccurrenceStep":
            let dateOfOccurrenceMaxDate = data.asFlowClaimDateOfOccurrenceStep?.maxDate
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
            )

            actions.append(
                .setMaxDateOfOccurrence(
                    maxDate: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
                )
            )
            actions.append(
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate)
            )

        case "FlowClaimSummaryStep":
            actions.append(.openSummaryScreen)

        case "FlowClaimDateOfOccurrencePlusLocationStep":
            let dateOfOccurrenceStep = data.asFlowClaimDateOfOccurrencePlusLocationStep?.dateOfOccurrenceStep
                .dateOfOccurrence
            let dateOfOccurrenceMaxDate = data.asFlowClaimDateOfOccurrencePlusLocationStep?.dateOfOccurrenceStep.maxDate
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
            )
            let locationStep = data.asFlowClaimDateOfOccurrencePlusLocationStep?.locationStep.location
            let possibleLocations = data.asFlowClaimDateOfOccurrencePlusLocationStep?.locationStep.options ?? []

            var dispValues: [Location] = []

            for element in possibleLocations {
                let list = Location(displayValue: element.displayName, value: element.value)
                dispValues.append(list)
            }
            actions.append(contentsOf: [
                .setMaxDateOfOccurrence(
                    maxDate: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
                ),
                .setListOfLocations(displayValues: dispValues),
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate),
            ])

        case "FlowClaimFailedStep":
            actions.append(
                .openFailureSceen
            )

        case "FlowClaimSuccessStep":
            actions.append(.openSuccessScreen)

        default:
            break
        }

        actions.append(.setLoadingState(action: action, state: nil))
        actions.forEach({ callback(.value($0)) })
    }
}

extension OctopusGraphQL.ClaimsFlowAudioRecordingMutation.Data: NextClaimSteps {
    func handleActions(
        for action: ClaimsAction,
        and callback: (Flow.Event<ClaimsAction>) -> Void,
        and store: ClaimsStore
    ) {
        let context = self.flowClaimAudioRecordingNext.context
        var actions = [ClaimsAction]()
        actions.append(.setNewClaimContext(context: context))
        let data = self.flowClaimAudioRecordingNext.currentStep

        switch data.__typename {

        case "FlowClaimPhoneNumberStep":
            let phoneNumber = data.asFlowClaimPhoneNumberStep?.phoneNumber ?? ""
            actions.append(.openPhoneNumberScreen(phoneNumber: phoneNumber))

        case "FlowClaimAudioRecordingStep":
            let questions = data.asFlowClaimAudioRecordingStep?.questions ?? [""]
            actions.append(.openAudioRecordingScreen(questions: questions))

        case "FlowClaimSingleItemStep":
            let prefferedCurrency = data.asFlowClaimSingleItemStep?.preferredCurrency
            let selectedProblems = data.asFlowClaimSingleItemStep?.selectedItemProblems
            let damages = data.asFlowClaimSingleItemStep?.availableItemProblems
            let models = data.asFlowClaimSingleItemStep?.availableItemModels
            let brands = data.asFlowClaimSingleItemStep?.availableItemBrands

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

            actions.append(contentsOf: [
                .setPrefferedCurrency(currency: prefferedCurrency?.rawValue ?? ""),
                .setSingleItemLists(
                    brands: dispValuesBrands,
                    models: dispValuesModels,
                    damages: dispValuesDamages
                ),
                .openSingleItemScreen(
                    maxDate: Date()
                ),
            ])

        case "FlowClaimSingleItemCheckoutStep":
            let payoutAmount = data.asFlowClaimSingleItemCheckoutStep?.payoutAmount
            let deductible = data.asFlowClaimSingleItemCheckoutStep?.deductible
            let depreciation = data.asFlowClaimSingleItemCheckoutStep?.depreciation
            let purchasePricePriceToShow = data.asFlowClaimSingleItemCheckoutStep?.price

            actions.append(contentsOf: [
                .setPurchasePrice(
                    priceOfPurchase:
                        Amount(
                            amount: purchasePricePriceToShow?.amount ?? 0,
                            currencyCode: purchasePricePriceToShow?.currencyCode.rawValue ?? ""
                        )
                ),
                .setPayoutAmountDeductibleDepreciation(
                    payoutAmount:
                        Amount(
                            amount: payoutAmount?.amount ?? 0,
                            currencyCode: payoutAmount?.currencyCode.rawValue ?? ""
                        ),
                    deductible:
                        Amount(
                            amount: deductible?.amount ?? 0,
                            currencyCode: deductible?.currencyCode.rawValue ?? ""
                        ),
                    depreciation:
                        Amount(
                            amount: depreciation?.amount ?? 0,
                            currencyCode: depreciation?.currencyCode.rawValue ?? ""
                        )
                ),
                .openCheckoutNoRepairScreen,
            ])

        case "FlowClaimLocationStep":
            let dateOfOccurrenceMaxDate = store.state.newClaim.maxDateOfoccurrance ?? ""
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate
            )

            actions.append(
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate)
            )

        case "FlowClaimDateOfOccurrenceStep":
            let dateOfOccurrenceMaxDate = data.asFlowClaimDateOfOccurrenceStep?.maxDate
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
            )

            actions.append(
                .setMaxDateOfOccurrence(
                    maxDate: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
                )
            )
            actions.append(
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate)
            )

        case "FlowClaimSummaryStep":
            actions.append(.openSummaryScreen)

        case "FlowClaimDateOfOccurrencePlusLocationStep":
            let dateOfOccurrenceStep = data.asFlowClaimDateOfOccurrencePlusLocationStep?.dateOfOccurrenceStep
                .dateOfOccurrence
            let dateOfOccurrenceMaxDate = data.asFlowClaimDateOfOccurrencePlusLocationStep?.dateOfOccurrenceStep.maxDate
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
            )
            let locationStep = data.asFlowClaimDateOfOccurrencePlusLocationStep?.locationStep.location
            let possibleLocations = data.asFlowClaimDateOfOccurrencePlusLocationStep?.locationStep.options ?? []

            var dispValues: [Location] = []

            for element in possibleLocations {
                let list = Location(displayValue: element.displayName, value: element.value)
                dispValues.append(list)
            }
            actions.append(contentsOf: [
                .setMaxDateOfOccurrence(
                    maxDate: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
                ),
                .setListOfLocations(displayValues: dispValues),
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate),
            ])

        case "FlowClaimFailedStep":
            actions.append(
                .openFailureSceen
            )

        case "FlowClaimSuccessStep":
            actions.append(.openSuccessScreen)

        default:
            break
        }

        actions.append(.setLoadingState(action: action, state: nil))
        actions.forEach({ callback(.value($0)) })
    }
}

extension OctopusGraphQL.ClaimsFlowSummaryMutation.Data: NextClaimSteps {
    func handleActions(
        for action: ClaimsAction,
        and callback: (Flow.Event<ClaimsAction>) -> Void,
        and store: ClaimsStore
    ) {
        let context = self.flowClaimSummaryNext.context
        var actions = [ClaimsAction]()
        actions.append(.setNewClaimContext(context: context))

        let data = self.flowClaimSummaryNext.currentStep

        switch data.__typename {

        case "FlowClaimPhoneNumberStep":
            let phoneNumber = data.asFlowClaimPhoneNumberStep?.phoneNumber ?? ""
            actions.append(.openPhoneNumberScreen(phoneNumber: phoneNumber))

        case "FlowClaimAudioRecordingStep":
            let questions = data.asFlowClaimAudioRecordingStep?.questions ?? [""]
            actions.append(.openAudioRecordingScreen(questions: questions))

        case "FlowClaimSingleItemStep":
            let prefferedCurrency = data.asFlowClaimSingleItemStep?.preferredCurrency
            let selectedProblems = data.asFlowClaimSingleItemStep?.selectedItemProblems
            let damages = data.asFlowClaimSingleItemStep?.availableItemProblems
            let models = data.asFlowClaimSingleItemStep?.availableItemModels
            let brands = data.asFlowClaimSingleItemStep?.availableItemBrands

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

            actions.append(contentsOf: [
                .setPrefferedCurrency(currency: prefferedCurrency?.rawValue ?? ""),
                .setSingleItemLists(
                    brands: dispValuesBrands,
                    models: dispValuesModels,
                    damages: dispValuesDamages
                ),
                .openSingleItemScreen(
                    maxDate: Date()
                ),
            ])

        case "FlowClaimSingleItemCheckoutStep":
            let payoutAmount = data.asFlowClaimSingleItemCheckoutStep?.payoutAmount
            let deductible = data.asFlowClaimSingleItemCheckoutStep?.deductible
            let depreciation = data.asFlowClaimSingleItemCheckoutStep?.depreciation
            let purchasePricePriceToShow = data.asFlowClaimSingleItemCheckoutStep?.price

            actions.append(contentsOf: [
                .setPurchasePrice(
                    priceOfPurchase:
                        Amount(
                            amount: purchasePricePriceToShow?.amount ?? 0,
                            currencyCode: purchasePricePriceToShow?.currencyCode.rawValue ?? ""
                        )
                ),
                .setPayoutAmountDeductibleDepreciation(
                    payoutAmount:
                        Amount(
                            amount: payoutAmount?.amount ?? 0,
                            currencyCode: payoutAmount?.currencyCode.rawValue ?? ""
                        ),
                    deductible:
                        Amount(
                            amount: deductible?.amount ?? 0,
                            currencyCode: deductible?.currencyCode.rawValue ?? ""
                        ),
                    depreciation:
                        Amount(
                            amount: depreciation?.amount ?? 0,
                            currencyCode: depreciation?.currencyCode.rawValue ?? ""
                        )
                ),
                .openCheckoutNoRepairScreen,
            ])

        case "FlowClaimLocationStep":
            let dateOfOccurrenceMaxDate = store.state.newClaim.maxDateOfoccurrance ?? ""
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate
            )

            actions.append(
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate)
            )

        case "FlowClaimDateOfOccurrenceStep":
            let dateOfOccurrenceMaxDate = data.asFlowClaimDateOfOccurrenceStep?.maxDate
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
            )

            actions.append(
                .setMaxDateOfOccurrence(
                    maxDate: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
                )
            )
            actions.append(
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate)
            )

        case "FlowClaimSummaryStep":
            actions.append(.openSummaryScreen)

        case "FlowClaimDateOfOccurrencePlusLocationStep":
            let dateOfOccurrenceStep = data.asFlowClaimDateOfOccurrencePlusLocationStep?.dateOfOccurrenceStep
                .dateOfOccurrence
            let dateOfOccurrenceMaxDate = data.asFlowClaimDateOfOccurrencePlusLocationStep?.dateOfOccurrenceStep.maxDate
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
            )
            let locationStep = data.asFlowClaimDateOfOccurrencePlusLocationStep?.locationStep.location
            let possibleLocations = data.asFlowClaimDateOfOccurrencePlusLocationStep?.locationStep.options ?? []

            var dispValues: [Location] = []

            for element in possibleLocations {
                let list = Location(displayValue: element.displayName, value: element.value)
                dispValues.append(list)
            }
            actions.append(contentsOf: [
                .setMaxDateOfOccurrence(
                    maxDate: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
                ),
                .setListOfLocations(displayValues: dispValues),
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate),
            ])

        case "FlowClaimFailedStep":
            actions.append(
                .openFailureSceen
            )

        case "FlowClaimSuccessStep":
            actions.append(.openSuccessScreen)

        default:
            break
        }

        actions.append(.setLoadingState(action: action, state: nil))
        actions.forEach({ callback(.value($0)) })
    }
}

extension OctopusGraphQL.ClaimsFlowSingleItemCheckoutMutation.Data: NextClaimSteps {
    func handleActions(
        for action: ClaimsAction,
        and callback: (Flow.Event<ClaimsAction>) -> Void,
        and store: ClaimsStore
    ) {
        let context = self.flowClaimSingleItemCheckoutNext.context
        var actions = [ClaimsAction]()
        actions.append(.setNewClaimContext(context: context))
        let data = self.flowClaimSingleItemCheckoutNext.currentStep

        switch data.__typename {

        case "FlowClaimPhoneNumberStep":
            let phoneNumber = data.asFlowClaimPhoneNumberStep?.phoneNumber ?? ""
            actions.append(.openPhoneNumberScreen(phoneNumber: phoneNumber))

        case "FlowClaimAudioRecordingStep":
            let questions = data.asFlowClaimAudioRecordingStep?.questions ?? [""]
            actions.append(.openAudioRecordingScreen(questions: questions))

        case "FlowClaimSingleItemStep":
            let prefferedCurrency = data.asFlowClaimSingleItemStep?.preferredCurrency
            let selectedProblems = data.asFlowClaimSingleItemStep?.selectedItemProblems
            let damages = data.asFlowClaimSingleItemStep?.availableItemProblems
            let models = data.asFlowClaimSingleItemStep?.availableItemModels
            let brands = data.asFlowClaimSingleItemStep?.availableItemBrands

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

            actions.append(contentsOf: [
                .setPrefferedCurrency(currency: prefferedCurrency?.rawValue ?? ""),
                .setSingleItemLists(
                    brands: dispValuesBrands,
                    models: dispValuesModels,
                    damages: dispValuesDamages
                ),
                .openSingleItemScreen(
                    maxDate: Date()
                ),
            ])

        case "FlowClaimSingleItemCheckoutStep":
            let payoutAmount = data.asFlowClaimSingleItemCheckoutStep?.payoutAmount
            let deductible = data.asFlowClaimSingleItemCheckoutStep?.deductible
            let depreciation = data.asFlowClaimSingleItemCheckoutStep?.depreciation
            let purchasePricePriceToShow = data.asFlowClaimSingleItemCheckoutStep?.price

            actions.append(contentsOf: [
                .setPurchasePrice(
                    priceOfPurchase:
                        Amount(
                            amount: purchasePricePriceToShow?.amount ?? 0,
                            currencyCode: purchasePricePriceToShow?.currencyCode.rawValue ?? ""
                        )
                ),
                .setPayoutAmountDeductibleDepreciation(
                    payoutAmount:
                        Amount(
                            amount: payoutAmount?.amount ?? 0,
                            currencyCode: payoutAmount?.currencyCode.rawValue ?? ""
                        ),
                    deductible:
                        Amount(
                            amount: deductible?.amount ?? 0,
                            currencyCode: deductible?.currencyCode.rawValue ?? ""
                        ),
                    depreciation:
                        Amount(
                            amount: depreciation?.amount ?? 0,
                            currencyCode: depreciation?.currencyCode.rawValue ?? ""
                        )
                ),
                .openCheckoutNoRepairScreen,
            ])

        case "FlowClaimLocationStep":
            let dateOfOccurrenceMaxDate = store.state.newClaim.maxDateOfoccurrance ?? ""
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate
            )

            actions.append(
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate)
            )

        case "FlowClaimDateOfOccurrenceStep":
            let dateOfOccurrenceMaxDate = data.asFlowClaimDateOfOccurrenceStep?.maxDate
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
            )

            actions.append(
                .setMaxDateOfOccurrence(
                    maxDate: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
                )
            )
            actions.append(
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate)
            )

        case "FlowClaimSummaryStep":
            actions.append(.openSummaryScreen)

        case "FlowClaimDateOfOccurrencePlusLocationStep":
            let dateOfOccurrenceStep = data.asFlowClaimDateOfOccurrencePlusLocationStep?.dateOfOccurrenceStep
                .dateOfOccurrence
            let dateOfOccurrenceMaxDate = data.asFlowClaimDateOfOccurrencePlusLocationStep?.dateOfOccurrenceStep.maxDate
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
            )
            let locationStep = data.asFlowClaimDateOfOccurrencePlusLocationStep?.locationStep.location
            let possibleLocations = data.asFlowClaimDateOfOccurrencePlusLocationStep?.locationStep.options ?? []

            var dispValues: [Location] = []

            for element in possibleLocations {
                let list = Location(displayValue: element.displayName, value: element.value)
                dispValues.append(list)
            }
            actions.append(contentsOf: [
                .setMaxDateOfOccurrence(
                    maxDate: dateOfOccurrenceMaxDate ?? store.state.newClaim.formatDateToString(date: Date())
                ),
                .setListOfLocations(displayValues: dispValues),
                .openDateOfOccurrenceScreen(maxDate: maxDateToDate),
            ])

        case "FlowClaimFailedStep":
            actions.append(
                .openFailureSceen
            )

        case "FlowClaimSuccessStep":
            actions.append(.openSuccessScreen)

        default:
            break
        }

        actions.append(.setLoadingState(action: action, state: nil))
        actions.forEach({ callback(.value($0)) })
    }
}

extension GraphQLMutation {
    func getFuture(action: ClaimsAction, store: ClaimsStore) -> FiniteSignal<ClaimsAction>?
    where Self.Data: NextClaimSteps {
        return FiniteSignal { callback in
            let disposeBag = DisposeBag()
            disposeBag += store.octopus.client.perform(mutation: self)
                .onValue { value in
                    value.handleActions(for: action, and: callback, and: store)
                }
                .onError { error in
                    callback(
                        .value(
                            .setLoadingState(
                                action: action,
                                state: .error(error: error.localizedDescription)
                            )
                        )
                    )
                }
            return disposeBag
        }
    }
}
