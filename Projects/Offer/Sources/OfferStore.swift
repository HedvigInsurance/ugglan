import Apollo
import Flow
import Foundation
import Presentation
import StoreKit
import hAnalytics
import hCore
import hGraphQL

public struct OfferState: StateProtocol {
    var isLoading = true
    var hasSignedQuotes = false
    var ids: [String] = []
    var selectedIds: [String] = []
    var startDates: [String: Date?] {
        switch currentVariant?.bundle.inception {
        case let .concurrent(concurrentInception):
            return concurrentInception.correspondingQuotes.reduce(into: [:]) { partialResult, id in
                partialResult[id] = concurrentInception.startDate?.localDateToDate ?? Date()
            }
        case let .independent(inceptions):
            return inceptions.reduce(into: [:]) { partialResult, inception in
                partialResult[inception.correspondingQuoteId] = inception.startDate?.localDateToDate ?? Date()
            }
        default:
            return [:]
        }
    }
    var swedishBankIDAutoStartToken: String? = nil
    var swedishBankIDStatusCode: String? = nil
    var offerData: OfferBundle? = nil
    var hasCheckedOutId: String? = nil
    var isUpdatingStartDates: Bool = false

    var dataCollectionEnabled: Bool {
        offerData?.possibleVariations
            .first(where: { variant in
                variant.bundle.quotes.first { quote in
                    quote.dataCollectionID != nil
                } != nil
            }) != nil
    }

    public var currentVariant: QuoteVariant? {
        if offerData?.possibleVariations.count == 1 {
            return offerData?.possibleVariations.first
        }

        return offerData?.possibleVariations
            .first(where: { variant in
                variant.id == selectedIds.joined(separator: "+").lowercased()
            })
    }

    var paymentConnection: PaymentConnection?

    // Quote Cart
    var quoteCartId: String? = nil
    var checkoutStatus: CheckoutStatus? = nil
    var accessToken: String? = nil

    var isQuoteCart: Bool {
        quoteCartId != nil
    }

    public init() {}
}

public enum OfferAction: ActionProtocol {
    case setLoading(isLoading: Bool)
    case sign(event: SignEvent)
    case startSwedishBankIDSign(autoStartToken: String)
    case setSwedishBankID(statusCode: String)
    case startSign
    case openChat
    case openCheckout
    case setIds(ids: [String], selectedIds: [String])
    case setSelectedIds(ids: [String])
    case query
    case setOfferBundle(bundle: OfferBundle)
    case refetch
    case openPerilDetail(peril: Perils)

    /// Start date events
    case setStartDates(dateMap: [String: Date?])
    case updateStartDates(dateMap: [String: Date?])
    case removeStartDate(id: String)

    /// Campaign events
    case removeRedeemedCampaigns
    case updateRedeemedCampaigns(discountCode: String)
    case didRedeemCampaigns
    case didRemoveCampaigns

    /// Quote Cart Events
    case setQuoteCartId(id: String)
    case setQuoteCart(quoteCart: QuoteCart)
    case setPaymentConnectionId(id: String)
    case startCheckout
    case requestQuoteCartSign
    case fetchAccessToken
    case setAccessToken(id: String)

    case failed(event: OfferStoreError)

    public enum SignEvent: Codable {
        case swedishBankId
        case simpleSign
        case done
        case failed
    }

    public enum OfferStoreError: Error, Codable {
        case checkoutUpdate
        case updateStartDate
        case updateRedeemedCampaigns
        case removeCampaigns
    }
}

public final class OfferStore: StateStore<OfferState, OfferAction> {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore

    func query(for ids: [String]) -> GraphQL.QuoteBundleQuery {
        GraphQL.QuoteBundleQuery(
            ids: ids,
            locale: Localization.Locale.currentLocale.asGraphQLLocale()
        )
    }

    func query(for quoteCart: String) -> GraphQL.QuoteCartQuery {
        GraphQL.QuoteCartQuery(
            locale: Localization.Locale.currentLocale.asGraphQLLocale(),
            id: quoteCart
        )
    }

    func query(for state: OfferState, cachePolicy: CachePolicy) -> FiniteSignal<OfferAction>? {
        if let quoteCartId = state.quoteCartId {
            return self.client
                .fetch(
                    query: query(for: quoteCartId),
                    cachePolicy: cachePolicy
                )
                .compactMap { data in
                    data.quoteCart.fragments.quoteCartFragment
                }
                .map { quoteCart in
                    return .setQuoteCart(quoteCart: .init(quoteCart: quoteCart))
                }
                .valueThenEndSignal
        } else {
            let query = self.query(for: state.ids)
            return client.fetch(query: query, cachePolicy: cachePolicy)
                .compactMap { data in
                    return OfferBundle(data: data)
                }
                .map {
                    return .setOfferBundle(bundle: $0)
                }
                .valueThenEndSignal
        }
    }

    internal var isLoadingSignal: CoreSignal<Read, Bool> {
        stateSignal.map { $0.offerData == nil }
    }

    public override func effects(
        _ getState: @escaping () -> OfferState,
        _ action: OfferAction
    ) -> FiniteSignal<OfferAction>? {
        switch action {
        case let .sign(event):
            if event == .done {
                hAnalyticsEvent.quotesSigned(
                    quoteIds: getState().selectedIds
                )
                .send()
                self.cancelEffect(.startSign)
            }
        case .startSign:
            if let _ = getState().quoteCartId {
                return FiniteSignal { callback in
                    let bag = DisposeBag()

                    bag += Signal(every: 0.25)
                        .onValue { _ in
                            callback(.value(.refetch))
                        }

                    bag += self.stateSignal
                        .filter(predicate: {
                            $0.checkoutStatus == .signed || $0.checkoutStatus == .completed
                        })
                        .onValue { _ in
                            callback(.value(.sign(event: .done)))
                        }

                    callback(.value(.requestQuoteCartSign))

                    return bag
                }
            } else {
                return signQuotesEffect()
            }
        case .query:
            return query(for: getState(), cachePolicy: .fetchIgnoringCacheData)
        case let .updateStartDates(dateMap):
            let state = getState()
            if let quoteCartId = state.quoteCartId, let currentVariant = state.currentVariant,
                let date = dateMap.values.first
            {
                return self.updateStartDatesQuoteCart(id: quoteCartId, date: date, currentVariant: currentVariant)
            }
            return self.updateStartDates(dateMap: dateMap)
        case .removeRedeemedCampaigns:
            return removeRedeemedCampaigns(quoteCartId: getState().quoteCartId)
        case let .updateRedeemedCampaigns(discountCode):
            return updateRedeemedCampaigns(discountCode: discountCode, quoteCartId: getState().quoteCartId)
        case .refetch:
            return query(for: getState(), cachePolicy: .fetchIgnoringCacheCompletely)
        case .didRedeemCampaigns, .didRemoveCampaigns:
            return FiniteSignal { callback in
                callback(.value(.refetch))
                return NilDisposer()
            }
        case .setOfferBundle, .setQuoteCart:
            return Signal(after: 0.5).map { .setLoading(isLoading: false) }
        case .startCheckout:
            return Signal(after: 0.1).map { .openCheckout }
        case .requestQuoteCartSign:
            let state = getState()
            if let quoteCartId = state.quoteCartId, let quoteId = state.currentVariant?.id {
                let ids = state.currentVariant?.bundle.quotes.compactMap { $0.id } ?? [quoteId]
                return requestQuoteCartSign(quoteCartId: quoteCartId, ids: ids)
            }
        case .fetchAccessToken:
            if let quoteCartId = getState().quoteCartId {
                return self.client.perform(mutation: GraphQL.CreateAccessTokenMutation(id: quoteCartId))
                    .compactMap { data in
                        data.quoteCartCreateAccessToken.accessToken
                    }
                    .map {
                        .setAccessToken(id: $0)
                    }
                    .valueThenEndSignal
            }
        default:
            return nil
        }

        return nil
    }

    override public func reduce(_ state: OfferState, _ action: OfferAction) -> OfferState {
        var newState = state

        switch action {
        case .query:
            newState.isLoading = true
            newState.offerData = nil
            newState.isUpdatingStartDates = false
        case let .setIds(ids, selectedIds):
            newState.ids = ids
            newState.selectedIds = selectedIds
            newState.offerData = nil
            newState.hasSignedQuotes = false
            newState.accessToken = nil
        case let .setSelectedIds(selectedIds):
            newState.selectedIds = selectedIds
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
        case let .setStartDates(dateMap):
            newState.isUpdatingStartDates = false

            guard var newOfferData = newState.offerData else { return newState }

            newOfferData.possibleVariations = newOfferData.possibleVariations.map { variant in
                var newVariant = variant

                switch newVariant.bundle.inception {
                case let .independent(independentInceptions):
                    let newInceptions = independentInceptions.map {
                        inception -> QuoteBundle.Inception.IndependentInception in
                        var copy = inception

                        dateMap.forEach { quoteId, startDate in
                            if inception.correspondingQuoteId == quoteId {
                                copy.startDate = startDate?.localDateString
                            }
                        }

                        return copy
                    }
                    newVariant.bundle.inception = .independent(inceptions: newInceptions)
                case .unknown:
                    break
                case .concurrent(let inception):
                    dateMap.forEach { quoteId, startDate in
                        if inception.correspondingQuotes.contains(where: { $0 == quoteId }) {
                            var newInception = inception
                            newInception.startDate = startDate?.localDateString
                            newVariant.bundle.inception = .concurrent(inception: newInception)
                        }
                    }
                }

                return newVariant
            }

            newState.offerData = newOfferData
        case let .setOfferBundle(bundle):
            newState.isUpdatingStartDates = false
            newState.offerData = bundle
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
        case .updateStartDates:
            newState.isUpdatingStartDates = true
        case .failed(event: .updateStartDate):
            newState.isUpdatingStartDates = false
        case let .setQuoteCartId(id):
            newState.quoteCartId = id
            newState.offerData = nil
            newState.hasSignedQuotes = false
            newState.accessToken = nil
        case let .setQuoteCart(quoteCart):
            newState.offerData = quoteCart.offerBundle
            newState.selectedIds = quoteCart.offerBundle?.quotes.map { $0.id } ?? []
            newState.checkoutStatus = quoteCart.checkoutStatus
            newState.paymentConnection = quoteCart.paymentConnection
        case let .setAccessToken(id):
            newState.accessToken = id
        default:
            break
        }

        return newState
    }
}

// Old offer state refactored
extension OfferStore {
    typealias Campaign = GraphQL.QuoteBundleQuery.Data.RedeemedCampaign

    private func updateRedeemedCampaigns(discountCode: String, quoteCartId: String?) -> FiniteSignal<OfferAction>? {
        if let quoteCartId = quoteCartId {
            return self
                .client
                .perform(
                    mutation: GraphQL.QuoteCartRedeemCampaignMutation(
                        code: discountCode,
                        id: quoteCartId,
                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
                    )
                )
                .compactMap {
                    $0.quoteCartAddCampaign.asQuoteCart?.fragments.quoteCartFragment
                }
                .map {
                    .setQuoteCart(quoteCart: .init(quoteCart: $0))
                }
                .valueThenEndSignal
        } else {
            return self.client
                .perform(
                    mutation: GraphQL.RedeemDiscountCodeMutation(
                        code: discountCode,
                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
                    )
                )
                .map { data in
                    guard data.redeemCodeV2.asSuccessfulRedeemResult?.campaigns != nil else {
                        return .failed(event: .updateRedeemedCampaigns)
                    }

                    return .didRedeemCampaigns
                }
                .valueThenEndSignal
        }
    }

    private func removeRedeemedCampaigns(quoteCartId: String?) -> FiniteSignal<OfferAction>? {
        if let quoteCartId = quoteCartId {
            return self.client
                .perform(
                    mutation: GraphQL.QuoteCartRemoveCampaignMutation(
                        id: quoteCartId,
                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
                    )
                )
                .compactMap { data in
                    data.quoteCartRemoveCampaign.asQuoteCart?.fragments.quoteCartFragment
                }
                .map {
                    .setQuoteCart(quoteCart: .init(quoteCart: $0))
                }
                .mapError { _ in
                    .failed(event: .removeCampaigns)
                }
                .valueThenEndSignal
        } else {
            return self.client.perform(mutation: GraphQL.RemoveDiscountMutation())
                .map { data in
                    .didRemoveCampaigns
                }
                .mapError { _ in
                    .failed(event: .removeCampaigns)
                }
                .valueThenEndSignal
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
                    return Future(error: OfferAction.OfferStoreError.checkoutUpdate)
                }

                return self.client
                    .fetch(
                        query: self.query(for: [quoteId]),
                        cachePolicy: .fetchIgnoringCacheData
                    )
                    .toVoid()
            }
    }

    private func updateStartDates(dateMap: [String: Date?]) -> FiniteSignal<OfferAction>? {
        let signals = dateMap.map { quoteId, date -> FiniteSignal<Result<(String, Date?)>> in
            guard let date = date else {
                return self.client.perform(mutation: GraphQL.RemoveStartDateMutation(id: quoteId))
                    .map { data in
                        guard data.removeStartDate.asCompleteQuote?.startDate == nil else {
                            return .failure(OfferAction.OfferStoreError.updateStartDate)
                        }

                        return .success((quoteId, date))
                    }
                    .mapError { _ in
                        .failure(OfferAction.OfferStoreError.updateStartDate)
                    }
                    .valueSignal
            }

            return self.client
                .perform(
                    mutation: GraphQL.ChangeStartDateMutation(
                        id: quoteId,
                        startDate: date.localDateString ?? ""
                    )
                )
                .map { data in
                    guard let date = data.editQuote.asCompleteQuote?.startDate?.localDateToDate else {
                        return .failure(OfferAction.OfferStoreError.updateStartDate)
                    }

                    return .success((quoteId, date))
                }
                .mapError { _ in
                    .failure(OfferAction.OfferStoreError.updateStartDate)
                }
                .valueSignal
        }

        return combineLatest(signals)
            .map { results in
                var didStrikeError = false
                var map: [String: Date?] = [:]

                results.forEach { result in
                    if let (quoteId, date) = try? result.get() {
                        map[quoteId] = date
                    } else {
                        didStrikeError = true
                    }
                }

                return didStrikeError ? .failed(event: .updateStartDate) : .setStartDates(dateMap: map)
            }
    }

    private func signQuotesEffect() -> FiniteSignal<Action> {
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

            self.client.perform(mutation: GraphQL.SignOrApproveQuotesMutation(ids: self.state.selectedIds))
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
