import Apollo
import Flow
import Foundation
import Presentation
import StoreKit
import hCore
import hGraphQL

public struct OfferState: StateProtocol {
    var hasSignedQuotes = false
    var ids: [String] = []
    var startDates: [String: Date?] = [:]
    var swedishBankIDAutoStartToken: String? = nil
    var swedishBankIDStatusCode: String? = nil
    var offerData: OfferBundle? = nil
    var hasCheckedOutId: String? = nil

    public init() {}
}

public enum OfferAction: ActionProtocol {

    case sign(event: SignEvent)
    case startSwedishBankIDSign(autoStartToken: String)
    case setSwedishBankID(statusCode: String)
    case startSign
    case openChat
    case query(ids: [String])
    case setOfferBundle(bundle: OfferBundle)

    /// Start date events
    case setStartDate(id: String, startDate: Date?)
    case updateStartDate(id: String, startDate: Date)
    case removeStartDate(id: String)

    case failed(event: OfferStoreError)

    public enum SignEvent: Codable {
        case swedishBankId
        case simpleSign
        case done
        case failed
    }
}

public final class OfferStore: StateStore<OfferState, OfferAction> {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore

    func query(for ids: [String]) -> GraphQL.QuoteBundleQuery {
        GraphQL.QuoteBundleQuery(
            ids: state.ids,
            locale: Localization.Locale.currentLocale.asGraphQLLocale()
        )
    }

    public override func effects(
        _ getState: @escaping () -> OfferState,
        _ action: OfferAction
    ) -> FiniteSignal<OfferAction>? {
        switch action {
        case let .sign(event):
            if event == .done {
                Analytics.track(
                    "QUOTES_SIGNED",
                    properties: [
                        "quoteIds": getState().ids
                    ]
                )
            }
        case .startSign:
            return signQuotesEffect()
        case .query(let ids):
            let query = self.query(for: ids)
            return client.fetch(query: query)
                .compactMap { data in
                    return OfferBundle(data: data)
                }
                .map {
                    return .setOfferBundle(bundle: $0)
                }
                .valueThenEndSignal
        case let .removeStartDate(id):
            return self.client
                .perform(
                    mutation: GraphQL.RemoveStartDateMutation(id: id)
                )
                .map { data in
                    if data.removeStartDate.asCompleteQuote?.startDate == nil {
                        return OfferAction.setStartDate(id: id, startDate: nil)
                    } else {
                        return .failed(error: .updateStartDate)
                    }
                }
                .valueThenEndSignal
        case let .updateStartDate(id, startDate):
            return self.updateStartDate(quoteId: id, date: startDate)
        default:
            return nil
        }

        return nil
    }

    override public func reduce(_ state: OfferState, _ action: OfferAction) -> OfferState {
        var newState = state

        switch action {
        case let .query(ids):
            newState.ids = ids
        case let .sign(event):
            if event == .done {
                newState.hasSignedQuotes = true
            }

            if event == .failed {
                newState.swedishBankIDStatusCode = nil
                newState.swedishBankIDAutoStartToken = nil
            }
        case let .startSwedishBankIDSign(autoStartToken):
            newState.swedishBankIDAutoStartToken = autoStartToken
        case let .setStartDate(id, startDate):
            newState.startDates[id] = startDate
        case let .setOfferBundle(bundle):
            newState.offerData = bundle
        default:
            break
        }

        return newState
    }
}

// Old offer state refactored
extension OfferStore {

    public enum OfferStoreError: Error, Codable {
        case checkoutUpdate
        case updateStartDate
        case updateRedeemedCampaigns
    }

    typealias Campaign = GraphQL.QuoteBundleQuery.Data.RedeemedCampaign

    private func updateCacheRedeemedCampaigns(
        campaigns: [Campaign]
    ) {
        //        self.store.update(query: self.query) { (storeData: inout GraphQL.QuoteBundleQuery.Data) in
        //            storeData.redeemedCampaigns = campaigns
        //        }
        //
        //        self.refetch()
    }

    func updateRedeemedCampaigns(discountCode: String) -> Future<Void> {
        return self.client
            .perform(
                mutation: GraphQL.RedeemDiscountCodeMutation(
                    code: discountCode,
                    locale: Localization.Locale.currentLocale.asGraphQLLocale()
                )
            )
            .flatMap { data in
                guard let campaigns = data.redeemCodeV2.asSuccessfulRedeemResult?.campaigns else {
                    return Future(error: OfferStoreError.updateRedeemedCampaigns)
                }

                let mappedCampaigns = campaigns.map { campaign in
                    Campaign.init(
                        displayValue: campaign.displayValue
                    )
                }

                self.updateCacheRedeemedCampaigns(
                    campaigns: mappedCampaigns
                )

                return Future()
            }
    }

    func removeRedeemedCampaigns() -> Future<Void> {
        return self.client.perform(mutation: GraphQL.RemoveDiscountMutation())
            .flatMap { data in
                self.updateCacheRedeemedCampaigns(campaigns: [])
                return Future()
            }
    }

    func checkoutUpdate(quoteId: String, email: String, ssn: String) -> Future<Void> {
        return self.client
            .perform(
                mutation: GraphQL.CheckoutUpdateMutation(quoteID: quoteId, email: email, ssn: ssn)
            )
            .flatMap { data in
                guard data.editQuote.asCompleteQuote?.email == email,
                    data.editQuote.asCompleteQuote?.ssn == ssn
                else {
                    return Future(error: OfferStoreError.checkoutUpdate)
                }

                return self.client
                    .fetch(
                        query: self.query(for: [quoteId]),
                        cachePolicy: .fetchIgnoringCacheData
                    )
                    .toVoid()
            }
    }

    func updateStartDate(quoteId: String, date: Date) -> FiniteSignal<OfferAction>? {
        return self.client
            .perform(
                mutation: GraphQL.ChangeStartDateMutation(
                    id: quoteId,
                    startDate: date.localDateString ?? ""
                )
            )
            .map { data in
                guard let date = data.editQuote.asCompleteQuote?.startDate?.localDateToDate else {
                    return .failed(event: .updateStartDate)
                }

                return .setStartDate(id: quoteId, startDate: date)
            }
            .valueThenEndSignal
    }

    func signQuotesEffect() -> FiniteSignal<Action> {
        let subscription = client.subscribe(subscription: GraphQL.SignStatusSubscription())
        let bag = DisposeBag()

        return FiniteSignal { callback in
            bag += subscription.map { $0.signStatus?.status?.signState == .completed }
                .filter(predicate: { $0 })
                .distinct()
                .onValue({ _ in
                    callback(.value(.sign(event: OfferAction.SignEvent.done)))
                    callback(.end)
                })

            bag += subscription.compactMap { $0.signStatus?.status?.collectStatus?.code }
                .distinct()
                .onValue({ code in
                    callback(.value(.setSwedishBankID(statusCode: code)))
                })

            self.client.perform(mutation: GraphQL.SignOrApproveQuotesMutation(ids: self.state.ids))
                .onResult { result in
                    switch result {
                    case .failure:
                        callback(.value(.sign(event: OfferAction.SignEvent.failed)))
                        callback(.end)
                    case let .success(data):
                        if let signQuoteReponse = data.signOrApproveQuotes.asSignQuoteResponse {
                            if signQuoteReponse.signResponse.asFailedToStartSign != nil {
                                callback(
                                    .value(
                                        .sign(
                                            event: OfferAction.SignEvent
                                                .failed
                                        )
                                    )
                                )
                                callback(.end)
                            } else if let session = signQuoteReponse
                                .signResponse
                                .asSwedishBankIdSession
                            {
                                callback(
                                    .value(
                                        .startSwedishBankIDSign(
                                            autoStartToken:
                                                session.autoStartToken
                                                ?? ""
                                        )
                                    )
                                )
                            } else if signQuoteReponse.signResponse.asSimpleSignSession
                                != nil
                            {
                                callback(
                                    .value(
                                        .sign(
                                            event: OfferAction.SignEvent
                                                .simpleSign
                                        )
                                    )
                                )
                            }
                        } else if let approvedResponse = data.signOrApproveQuotes
                            .asApproveQuoteResponse
                        {
                            if approvedResponse.approved == true {
                                callback(
                                    .value(.sign(event: OfferAction.SignEvent.done))
                                )
                                callback(.end)
                            }
                        } else {
                            callback(.value(.sign(event: OfferAction.SignEvent.failed)))
                            callback(.end)
                        }
                    }
                }

            return bag
        }
    }
}
