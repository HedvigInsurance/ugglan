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
    var selectedInsuranceTypes = [String]()
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
    case openInsurableLimit(limit: InsurableLimits)
    case openQuoteCoverage(quote: QuoteBundle.Quote)
    case openDocument(url: URL)
    case openFAQ(item: QuoteBundle.FrequentlyAskedQuestion)
    case setPaymentConnectionID(id: String)

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
    case setQuoteCartId(id: String, insuranceTypes: [String])
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
        case cancelled
    }

    public enum OfferStoreError: Error, Codable {
        case checkoutUpdate
        case updateStartDate
        case updateRedeemedCampaigns
        case removeCampaigns
    }
}

public final class OfferStore: StateStore<OfferState, OfferAction> {
    @Inject var giraffe: hGiraffe

    func query(for ids: [String]) -> GiraffeGraphQL.QuoteBundleQuery {
        GiraffeGraphQL.QuoteBundleQuery(
            ids: ids,
            locale: Localization.Locale.currentLocale.asGraphQLLocale()
        )
    }

    func query(for quoteCart: String) -> GiraffeGraphQL.QuoteCartQuery {
        GiraffeGraphQL.QuoteCartQuery(
            locale: Localization.Locale.currentLocale.asGraphQLLocale(),
            id: quoteCart
        )
    }

    func query(for state: OfferState, cachePolicy: CachePolicy) -> FiniteSignal<OfferAction>? {
        if let quoteCartId = state.quoteCartId {
            return self.giraffe.client
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
            return giraffe.client.fetch(query: query, cachePolicy: cachePolicy)
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
                self.cancelEffect(.startSign)
            } else if event == .cancelled {
                self.cancelEffect(.startSign)
            }
        case .startSign:
            if let _ = getState().quoteCartId {
                return FiniteSignal { callback in
                    let bag = DisposeBag()

                    bag += Signal(every: 0.5)
                        .atValue { _ in
                            callback(.value(.refetch))
                        }
                        .delay(by: 130)
                        .onValue { _ in
                            bag.dispose()
                            callback(.value(.sign(event: .failed)))
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
            }
        case .query:
            return query(for: getState(), cachePolicy: .fetchIgnoringCacheData)
        case let .updateStartDates(dateMap):
            let state = getState()
            if let quoteCartId = state.quoteCartId,
                let currentVariant = state.currentVariant,
                let date = dateMap.values.first
            {
                return self.updateStartDatesQuoteCart(id: quoteCartId, date: date, currentVariant: currentVariant)
            }
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
        case .setOfferBundle:
            return Signal(after: 0.5).map { .setLoading(isLoading: false) }
        case let .setQuoteCart(cart):
            let allQuoteIds = cart.offerBundle?.possibleVariations
                .flatMap({ variant in
                    variant.bundle.quotes
                })
                .compactMap { quote in quote.id }
            return Signal(after: 0.5).map { .setLoading(isLoading: false) }
        case .startCheckout:
            return Signal(after: 0.1).map { .openCheckout }
        case .requestQuoteCartSign:
            let state = getState()
            if let quoteCartId = state.quoteCartId, let quoteId = state.currentVariant?.id {
                let ids = state.currentVariant?.bundle.quotes.compactMap { $0.id } ?? [quoteId]
                return requestQuoteCartSign(quoteCartId: quoteCartId, ids: ids.unique())
            }
        case .fetchAccessToken:
            if let quoteCartId = getState().quoteCartId {
                return self.giraffe.client
                    .perform(
                        mutation: GiraffeGraphQL.CreateAccessTokenMutation(id: quoteCartId)
                    )
                    .compactMap { data in
                        data.quoteCartCreateAccessToken.accessToken
                    }
                    .map {
                        .setAccessToken(id: $0)
                    }
                    .valueThenEndSignal
            }
        case let .setPaymentConnectionID(paymentConnectionID):
            if let quoteCartId = getState().quoteCartId {
                return self.giraffe.client
                    .perform(
                        mutation: GiraffeGraphQL.QuoteCartSetPaymentConnectionIdMutation(
                            id: quoteCartId,
                            paymentConnectionID: paymentConnectionID,
                            locale: Localization.Locale.currentLocale.asGraphQLLocale()
                        )
                    )
                    .compactMap { data in
                        data.quoteCartAddPaymentToken.asQuoteCart?.fragments.quoteCartFragment
                    }
                    .map {
                        .setQuoteCart(quoteCart: .init(quoteCart: $0))
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
        case .requestQuoteCartSign:
            newState.checkoutStatus = nil
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
        case let .setQuoteCartId(id, selectedInsuranceTypes):
            newState.quoteCartId = id
            newState.selectedInsuranceTypes = selectedInsuranceTypes
            newState.offerData = nil
            newState.hasSignedQuotes = false
            newState.accessToken = nil
            newState.selectedIds = []
        case let .setQuoteCart(quoteCart):
            newState.offerData = quoteCart.offerBundle

            if newState.selectedIds.isEmpty {
                let allQuotes = newState.offerData?.possibleVariations
                    .flatMap({ variant in
                        variant.bundle.quotes
                    })

                let selectedIds = allQuotes?
                    .filter({ quote in
                        newState.selectedInsuranceTypes.contains(quote.insuranceType ?? "")
                            || newState.selectedInsuranceTypes.contains(quote.typeOfContract)
                    })
                    .compactMap({ quote in quote.id })

                if selectedIds?.isEmpty ?? true {
                    newState.selectedIds = Array(Set(allQuotes?.compactMap { $0.id } ?? []))
                } else {
                    newState.selectedIds = Array(Set(selectedIds ?? []))
                }
            }

            newState.checkoutStatus = quoteCart.checkoutStatus
            newState.paymentConnection = quoteCart.paymentConnection
            newState.swedishBankIDStatusCode = quoteCart.checkoutStatusText
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
    typealias Campaign = GiraffeGraphQL.QuoteBundleQuery.Data.RedeemedCampaign

    private func updateRedeemedCampaigns(discountCode: String, quoteCartId: String?) -> FiniteSignal<OfferAction>? {
        if let quoteCartId = quoteCartId {
            return self
                .giraffe
                .client
                .perform(
                    mutation: GiraffeGraphQL.QuoteCartRedeemCampaignMutation(
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
            return self.giraffe.client
                .perform(
                    mutation: GiraffeGraphQL.RedeemDiscountCodeMutation(
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
            return self.giraffe.client
                .perform(
                    mutation: GiraffeGraphQL.QuoteCartRemoveCampaignMutation(
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
            return self.giraffe.client.perform(mutation: GiraffeGraphQL.RemoveDiscountMutation())
                .map { data in
                    .didRemoveCampaigns
                }
                .mapError { _ in
                    .failed(event: .removeCampaigns)
                }
                .valueThenEndSignal
        }
    }
}
