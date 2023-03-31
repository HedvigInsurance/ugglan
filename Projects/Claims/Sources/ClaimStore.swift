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
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client.perform(mutation: mutation)
                    .onValue { data in
                        callback(.value(.setNewClaimContext(context: data.flowClaimStart.context)))
                        callback(
                            .value(
                                .setNewClaim(
                                    from: NewClaim(id: data.flowClaimStart.id, context: data.flowClaimStart.context)
                                )
                            )
                        )
                        data.flowClaimStart.fragments.flowClaimFragment.executeNextStepActions(
                            for: action,
                            callback: callback
                        )
                        callback(.value(.setLoadingState(action: action, state: nil)))
                    }
                    .onError { error in
                        callback(
                            .value(
                                .setLoadingState(
                                    action: action,
                                    state: .error(error: L10n.General.errorBody)
                                )
                            )
                        )
                    }
                return disposeBag
            }
        case let .claimNextPhoneNumber(phoneNumberInput):
            self.send(.setLoadingState(action: action, state: .loading))
            let phoneNumber = OctopusGraphQL.FlowClaimPhoneNumberInput(phoneNumber: phoneNumberInput)
            let mutation = OctopusGraphQL.FlowClaimPhoneNumberNextMutation(input: phoneNumber, context: newClaimContext)
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client.perform(mutation: mutation)
                    .onValue { data in
                        callback(.value(.setNewClaimContext(context: data.flowClaimPhoneNumberNext.context)))
                        data.flowClaimPhoneNumberNext.fragments.flowClaimFragment.executeNextStepActions(
                            for: action,
                            callback: callback
                        )
                        callback(.value(.setLoadingState(action: action, state: nil)))
                    }
                    .onError { error in
                        callback(
                            .value(
                                .setLoadingState(
                                    action: action,
                                    state: .error(error: L10n.General.errorBody)
                                )
                            )
                        )
                    }
                return disposeBag
            }
        case let .claimNextDateOfOccurrence(dateOfOccurrence):
            let dateString = state.newClaim.formatDateToString(date: dateOfOccurrence)
            let dateOfOccurrenceInput = OctopusGraphQL.FlowClaimDateOfOccurrenceInput(dateOfOccurrence: dateString)
            let mutation = OctopusGraphQL.FlowClaimDateOfOccurrenceNextMutation(
                input: dateOfOccurrenceInput,
                context: newClaimContext
            )
            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: mutation
                    )
                    .onValue { data in
                        var actions = [ClaimsAction]()
                        actions.append(.setNewClaimContext(context: data.flowClaimDateOfOccurrenceNext.context))
                        actions.append(.setNewDate(dateOfOccurrence: dateString))
                        actions.append(.setLoadingState(action: action, state: nil))
                        actions.forEach({ callback(.value($0)) })
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
                        mutation: OctopusGraphQL.FlowClaimLocationNextMutation(
                            input: locationInput,
                            context: newClaimContext
                        )
                    )
                    .onValue { data in
                        var actions = [ClaimsAction]()
                        actions.append(.setNewClaimContext(context: data.flowClaimLocationNext.context))
                        actions.append(.setNewLocation(location: Location(displayValue: displayValue, value: value)))
                        actions.append(.setLoadingState(action: action, state: nil))
                        actions.forEach({ callback(.value($0)) })
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
            let mutation = OctopusGraphQL.FlowClaimDateOfOccurrencePlusLocationNextMutation(
                input: dateAndLocationInput,
                context: newClaimContext
            )
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client.perform(mutation: mutation)
                    .onValue { data in
                        callback(
                            .value(.setNewClaimContext(context: data.flowClaimDateOfOccurrencePlusLocationNext.context))
                        )
                        data.flowClaimDateOfOccurrencePlusLocationNext.fragments.flowClaimFragment
                            .executeNextStepActions(for: action, callback: callback)
                        callback(.value(.setLoadingState(action: action, state: nil)))
                    }
                    .onError { error in
                        callback(
                            .value(
                                .setLoadingState(
                                    action: action,
                                    state: .error(error: L10n.General.errorBody)
                                )
                            )
                        )
                    }
                return disposeBag
            }
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
                            let mutation = OctopusGraphQL.FlowClaimAudioRecordingNextMutation(
                                input: audioInput,
                                context: newClaimContext
                            )
                            disposeBag += self.octopus.client.perform(mutation: mutation)
                                .onValue { data in
                                    callback(
                                        .value(.setNewClaimContext(context: data.flowClaimAudioRecordingNext.context))
                                    )
                                    data.flowClaimAudioRecordingNext.fragments.flowClaimFragment.executeNextStepActions(
                                        for: action,
                                        callback: callback
                                    )
                                    callback(.value(.setLoadingState(action: action, state: nil)))
                                }
                                .onError { error in
                                    callback(
                                        .value(
                                            .setLoadingState(
                                                action: action,
                                                state: .error(error: L10n.General.errorBody)
                                            )
                                        )
                                    )
                                }

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
            let mutation = OctopusGraphQL.FlowClaimSingleItemNextMutation(
                input: singleItemInput,
                context: newClaimContext
            )
            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: mutation
                    )
                    .onValue { data in
                        var actions = [ClaimsAction]()
                        actions.append(.setNewClaimContext(context: data.flowClaimSingleItemNext.context))
                        actions.append(
                            .setPurchasePrice(
                                priceOfPurchase: Amount(
                                    amount: purchasePrice,
                                    currencyCode: self.state.newClaim.prefferedCurrency ?? ""
                                )
                            )
                        )
                        data.flowClaimSingleItemNext.fragments.flowClaimFragment.executeNextStepActions(
                            for: action,
                            callback: callback
                        )
                        actions.append(.setLoadingState(action: action, state: nil))
                        actions.forEach({ callback(.value($0)) })
                    }
                    .onError { error in
                        callback(
                            .value(.setLoadingState(action: action, state: .error(error: error.localizedDescription)))
                        )
                    }
                return NilDisposer()
            }

        case .claimNextSummary:
            send(.setLoadingState(action: action, state: .loading))
            let summaryInput = state.newClaim.returnSummaryInformation()
            let mutation = OctopusGraphQL.FlowClaimSummaryNextMutation(
                input: summaryInput,
                context: newClaimContext
            )
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client.perform(mutation: mutation)
                    .onValue { data in
                        callback(.value(.setNewClaimContext(context: data.flowClaimSummaryNext.context)))
                        data.flowClaimSummaryNext.fragments.flowClaimFragment.executeNextStepActions(
                            for: action,
                            callback: callback
                        )
                        callback(.value(.setLoadingState(action: action, state: nil)))
                    }
                    .onError { error in
                        callback(
                            .value(
                                .setLoadingState(
                                    action: action,
                                    state: .error(error: L10n.General.errorBody)
                                )
                            )
                        )
                    }
                return disposeBag
            }
        case .claimNextSingleItemCheckout:
            send(.setLoadingState(action: action, state: .loading))
            let claimSingleItemCheckoutInput = state.newClaim.returnSingleItemCheckoutInfo()
            let mutation = OctopusGraphQL.FlowClaimSingleItemCheckoutNextMutation(
                input: claimSingleItemCheckoutInput,
                context: newClaimContext
            )
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client.perform(mutation: mutation)
                    .onValue { data in
                        callback(.value(.setNewClaimContext(context: data.flowClaimSingleItemCheckoutNext.context)))
                        data.flowClaimSingleItemCheckoutNext.fragments.flowClaimFragment.executeNextStepActions(
                            for: action,
                            callback: callback
                        )
                        callback(.value(.setLoadingState(action: action, state: nil)))
                    }
                    .onError { error in
                        callback(
                            .value(
                                .setLoadingState(
                                    action: action,
                                    state: .error(error: L10n.General.errorBody)
                                )
                            )
                        )
                    }
                return disposeBag
            }
        case .fetchCommonClaimsForSelection:
            self.send(.setLoadingState(action: action, state: .loading))
            let getEntryPointsClaimsClient: GetEntryPointsClaimsClient = Dependencies.shared.resolve()
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag +=
                    getEntryPointsClaimsClient.execute()
                    .onValue { model in
                        callback(.value(.setCommonClaimsForSelection(model)))
                        callback(.value(.setLoadingState(action: action, state: nil)))
                    }
                    .onError { error in
                        callback(
                            .value(.setLoadingState(action: action, state: .error(error: error.localizedDescription)))
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
            newState.newClaim.deductible = nil
            newState.newClaim.depreciation = nil
            newState.newClaim.prefferedCurrency = nil
            newState.newClaim.maxDateOfoccurrance = nil
        case let .setSingleItemLists(brands, models, damages, defaultDamages):
            newState.newClaim.listOfDamage = damages
            newState.newClaim.defaultChosenDamages = defaultDamages
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
        case let .setItemBrand(brand):
            newState.newClaim.chosenModel = nil
            newState.newClaim.chosenBrand = brand
            newState.newClaim.filteredListOfModels = newState.newClaim.getListOfModels(for: brand)
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
        case let .stepModelAction(action):
            switch action {
            case .setPhoneNumber(let model):
                newState.phoneNumberStep = model
            }
        default:
            break
        }
        return newState
    }
}

extension OctopusGraphQL.FlowClaimFragment {
    func executeNextStepActions(for action: ClaimsAction, callback: (Event<ClaimsAction>) -> Void) {
        let currentStep = self.currentStep
        var actions = [ClaimsAction]()
        if let step = currentStep.fragments.flowClaimPhoneNumberStepFragment {
            let model = ClaimFlowPhoneNumberStepModel(with: step)
            actions.append(.stepModelAction(action: .setPhoneNumber(model: model)))
            actions.append(.navigationAction(action: .openPhoneNumberScreen(model: model)))
        } else if let step = currentStep.asFlowClaimAudioRecordingStep {
            actions.append(.navigationAction(action: .openAudioRecordingScreen(questions: step.questions)))
        } else if let step = currentStep.asFlowClaimSingleItemStep {
            let selectedDamages: [Damage] = step.selectedItemProblems.map({
                Damage(displayName: $0.displayValue, itemProblemId: $0.displayValue)
            })
            let damages: [Damage] =
                step.availableItemProblems?
                .map({ Damage(displayName: $0.displayName, itemProblemId: $0.itemProblemId) }) ?? []
            let models: [Model] =
                step.availableItemModels?
                .map({
                    Model(
                        displayName: $0.displayName,
                        itemBrandId: $0.itemBrandId,
                        itemModelId: $0.itemModelId,
                        itemTypeID: $0.itemTypeId
                    )
                }) ?? []
            let brands: [Brand] =
                step.availableItemBrands?.map({ Brand(displayName: $0.displayName, itemBrandId: $0.itemBrandId) }) ?? []
            actions.append(.setPrefferedCurrency(currency: step.preferredCurrency.rawValue))
            actions.append(
                .setSingleItemLists(brands: brands, models: models, damages: damages, defaultDamages: selectedDamages)
            )
            actions.append(.navigationAction(action: .openSingleItemScreen(maxDate: Date())))
        } else if let step = currentStep.asFlowClaimSingleItemCheckoutStep {
            actions.append(.setPurchasePrice(priceOfPurchase: Amount(with: step.price.fragments.moneyFragment)))
            actions.append(
                .setPayoutAmountDeductibleDepreciation(
                    payoutAmount: Amount(with: step.payoutAmount.fragments.moneyFragment),
                    deductible: Amount(with: step.deductible.fragments.moneyFragment),
                    depreciation: Amount(with: step.depreciation.fragments.moneyFragment)
                )
            )
            actions.append(.navigationAction(action: .openCheckoutNoRepairScreen))
        } else if let step = currentStep.asFlowClaimLocationStep {
            let store: ClaimsStore = globalPresentableStoreContainer.get()
            let maxDateToDate = store.state.newClaim.formatStringToDate(
                dateString: store.state.newClaim.maxDateOfoccurrance ?? ""
            )
            actions.append(.navigationAction(action: .openDateOfOccurrenceScreen(maxDate: maxDateToDate)))
        } else if let step = currentStep.asFlowClaimDateOfOccurrenceStep {
            let store: ClaimsStore = globalPresentableStoreContainer.get()
            let maxDateToDate = store.state.newClaim.formatStringToDate(dateString: step.maxDate)
            actions.append(.setMaxDateOfOccurrence(maxDate: step.maxDate))
            actions.append(.navigationAction(action: .openDateOfOccurrenceScreen(maxDate: maxDateToDate)))
        } else if let step = currentStep.asFlowClaimSummaryStep {
            actions.append(.navigationAction(action: .openSummaryScreen))
        } else if let step = currentStep.asFlowClaimDateOfOccurrencePlusLocationStep {
            let store: ClaimsStore = globalPresentableStoreContainer.get()
            let dateOfOccurrenceStep = step.dateOfOccurrenceStep.dateOfOccurrence
            let dateOfOccurrenceMaxDate = step.dateOfOccurrenceStep.maxDate
            let maxDateToDate = store.state.newClaim.formatStringToDate(dateString: dateOfOccurrenceMaxDate)
            let locations = step.locationStep.options.map({ Location(displayValue: $0.displayName, value: $0.value) })

            actions.append(.setMaxDateOfOccurrence(maxDate: dateOfOccurrenceMaxDate))
            actions.append(.setListOfLocations(displayValues: locations))
            actions.append(.navigationAction(action: .openDateOfOccurrenceScreen(maxDate: maxDateToDate)))
        } else if let step = currentStep.asFlowClaimFailedStep {
            actions.append(.navigationAction(action: .openFailureSceen))
        } else if let step = currentStep.asFlowClaimSuccessStep {
            if case .claimNextSingleItemCheckout = action {
                actions.append(.navigationAction(action: .openCheckoutTransferringDoneScreen))
            } else {
                actions.append(.navigationAction(action: .openSuccessScreen))
            }
        } else {
            actions.append(.navigationAction(action: .openUpdateAppScreen))
        }
        actions.forEach { action in
            callback(.value(action))
        }
    }
}
