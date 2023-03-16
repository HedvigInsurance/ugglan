import Apollo
import Contracts
import Flow
import Odyssey
import Presentation
import hCore
import hGraphQL

public struct ClaimsState: StateProtocol {
    var claims: [Claim]? = nil
    var commonClaims: [CommonClaim]? = nil
    var newClaims: NewClaim? = nil  //change to array?

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

    case openPhoneNumberScreen(from: ClaimsOrigin, context: String)
    case submitClaimPhoneNumber(phoneNumberInput: String)

    case openDateOfOccurrenceScreen(from: ClaimsOrigin, dateOfOccurrence: Date?, location: String?, context: String)  //?
    case openLocationPicker(context: String)

    case submitClaimDateOfOccurrence(dateOfOccurrence: Date)
    case submitClaimLocation(location: String)

    case openDatePicker

    case openModelPicker
    case openSuccessScreen
    case submitClaimAudioRecordingOrInfo
    case openSummaryScreen
    case openSummaryEditScreen
    case openDamagePickerScreen
    case openCheckoutNoRepairScreen
    case openCheckoutTransferringScreen
    case openCheckoutTransferringDoneScreen

    case startClaim(from: ClaimsOrigin)
    case claimNextPhoneNumber(from: ClaimsOrigin, phoneNumber: String, context: String)
    case claimNextDateOfOccurrence(from: ClaimsOrigin, dateOfOccurrence: Date, context: String)
    case claimNextLocation(from: ClaimsOrigin, location: String, context: String)

    case setNewClaim(details: NewClaim)
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
            /** START **/

            let startInput = OctopusGraphQL.FlowClaimStartInput(entrypointId: nil)  //need to be UUID

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.FlowClaimStartMutation(input: startInput)  // 5dddcab9-a0fc-4cb7-94f3-2785693e8803 för single item
                    )
                    .onValue { data in

                        let contextInput = data.flowClaimStart.context

                        let data = data.flowClaimStart.currentStep

                        if let dataStep = data.asFlowClaimPhoneNumberStep {

                            [
                                .openPhoneNumberScreen(from: claimsOrigin, context: contextInput)
                            ]
                            .forEach { element in
                                callback(.value(element))
                            }

                        } else if let dataStep = data.asFlowClaimDateOfOccurrenceStep {

                            [
                                //                                .submitClaimOccuranceScreen(from: claimsOrigin)
                            ]
                            .forEach { element in
                                callback(.value(element))
                            }

                        } else if let dataStep = data.asFlowClaimAudioRecordingStep {

                        } else if let dataStep = data.asFlowClaimLocationStep {

                        } else if let dataStep = data.asFlowClaimFailedStep {

                        } else if let dataStep = data.asFlowClaimSuccessStep {

                        }
                    }

                return NilDisposer()

            }
        case let .claimNextPhoneNumber(claimsOrigin, phoneNumber, contextInput):

            var phoneNumber = OctopusGraphQL.FlowClaimPhoneNumberInput(phoneNumber: "0730776671")

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.ClaimsFlowPhoneNumberMutation(
                            input: phoneNumber,
                            context: contextInput
                        )
                    )
                    .onValue { data in

                        let data = data.flowClaimPhoneNumberNext.currentStep

                        if let dataStep = data.asFlowClaimDateOfOccurrenceStep {

                            [
                                .openDateOfOccurrenceScreen(
                                    from: claimsOrigin,
                                    dateOfOccurrence: nil,
                                    location: nil,
                                    context: contextInput
                                )
                            ]
                            .forEach { element in
                                callback(.value(element))
                            }

                        } else if let dataStep = data.asFlowClaimFailedStep {

                        } else {

                        }
                    }
                    .onError { error in
                        print(error)
                    }
                return NilDisposer()

            }
        case let .claimNextDateOfOccurrence(claimsOrigin, dateOfOccurrence, context):

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: dateOfOccurrence)

            var dateOfOccurrenceInput = OctopusGraphQL.FlowClaimDateOfOccurrenceInput(dateOfOccurrence: dateString)

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.ClaimsFlowDateOfOccurrenceMutation(
                            input: dateOfOccurrenceInput,
                            context: context
                        )
                    )
                    .onValue { data in
                        [
                            .setNewClaim(
                                details:
                                    NewClaim(
                                        dateOfOccurrence: dateString,
                                        location: ""  //?
                                            //                                                data.flowClaimDateOfOccurrenceNext.currentStep.asFlowClaimDateOfOccurrenceStep?.dateOfOccurrence ?? ""
                                    )
                            ),
                            .openDateOfOccurrenceScreen(
                                from: claimsOrigin,
                                dateOfOccurrence: dateOfOccurrence,
                                location: nil,
                                context: context
                            ),
                        ]
                        .forEach { element in
                            callback(.value(element))
                        }

                        let data = data.flowClaimDateOfOccurrenceNext.currentStep

                        if let dataStep = data.asFlowClaimAudioRecordingStep {

                        } else if let dataStep = data.asFlowClaimFailedStep {

                            //                            [
                            //                                .openDateOfOccurrenceScreen(from: claimsOrigin, dateOfOccurrence: dateOfOccurrence, context: context),
                            ////                                .openLocationPicker(context: context)
                            //                            ]
                            //                                .forEach { element in
                            //                                    callback(.value(element))
                            //                                }

                        } else if let dataStep = data.asFlowClaimLocationStep {

                            //                            [
                            //                                .openDateOfOccurrenceScreen(from: claimsOrigin, dateOfOccurrence: dateOfOccurrence, context: context),
                            ////                                .openLocationPicker(context: context)
                            //                            ]
                            //                                .forEach { element in
                            //                                    callback(.value(element))
                            //                                }

                        } else {

                        }

                    }
                    .onError { error in
                        print(error)

                    }

                return NilDisposer()

            }

        case let .claimNextLocation(claimsOrigin, location, context):

            let locationInput = OctopusGraphQL.FlowClaimLocationInput(location: location)

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.ClaimsFlowLocationMutation(input: locationInput, context: context)
                    )
                    .onValue { data in

                        [
                            .setNewClaim(
                                details:
                                    NewClaim(
                                        dateOfOccurrence: "String",
                                        location: location  //?
                                            //                                                data.flowClaimDateOfOccurrenceNext.currentStep.asFlowClaimDateOfOccurrenceStep?.dateOfOccurrence ?? ""
                                    )
                            ),
                            .openDateOfOccurrenceScreen(
                                from: claimsOrigin,
                                dateOfOccurrence: "",
                                location: location,
                                context: context
                            ),  //add location?
                        ]
                        .forEach { element in
                            callback(.value(element))
                        }

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

        case let .setNewClaim(details):
            newState.newClaims = details

        default:
            break
        }

        return newState
    }
}
