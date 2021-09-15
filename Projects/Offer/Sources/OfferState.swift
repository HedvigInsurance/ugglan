import Apollo
import Flow
import Foundation
import hCore
import hGraphQL

class OldOfferState {
    @PresentableStore var offerStore: OfferStore
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
    let ids: [String]

    public init(
        ids: [String]
    ) {
        self.ids = ids
    }

    private var bag = DisposeBag()

    private let openChatCallbacker = Callbacker<Void>()
    var openChatSignal: Signal<Void> {
        openChatCallbacker.providedSignal
    }

    @ReadWriteState var hasSignedQuotes = false

    lazy var isLoadingSignal: ReadSignal<Bool> = {
        return client.fetch(query: query).valueSignal.plain().map { _ in false }.delay(by: 0.5)
            .readable(initial: true)
    }()

    var query: GraphQL.QuoteBundleQuery {
        GraphQL.QuoteBundleQuery(ids: ids, locale: Localization.Locale.currentLocale.asGraphQLLocale())
    }

    var dataSignal: CoreSignal<Plain, GraphQL.QuoteBundleQuery.Data> {
        client.watch(query: query)
    }

    var quotesSignal: CoreSignal<Plain, [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote]> {
        dataSignal.map { $0.quoteBundle.quotes }
    }

    var signStatusSubscription: CoreSignal<Plain, GraphQL.SignStatusSubscription.Data> {
        client.subscribe(subscription: GraphQL.SignStatusSubscription())
    }

    func openChat() {
        openChatCallbacker.callAll()
    }

    enum UpdateStartDateError: Error {
        case failed
    }

    enum UpdateRedeemedCampaigns: Error {
        case failed
    }

    private func updateCacheStartDate(quoteId: String, date: String?) {
        self.store.update(query: self.query) {
            (storeData: inout GraphQL.QuoteBundleQuery.Data) in
            storeData.quoteBundle.inception.asConcurrentInception?.startDate = date

            guard let allInceptions = storeData.quoteBundle.inception.asIndependentInceptions?.inceptions
            else {
                return
            }

            typealias Inception = GraphQL.QuoteBundleQuery.Data.QuoteBundle.Inception
                .AsIndependentInceptions.Inception

            let updatedInceptions = allInceptions.map { inception -> Inception in
                guard inception.correspondingQuote.asCompleteQuote?.id == quoteId else {
                    return inception
                }
                var inception = inception
                inception.startDate = date
                return inception
            }

            storeData.quoteBundle.inception.asIndependentInceptions?.inceptions = updatedInceptions
        }
    }

    typealias Campaign = GraphQL.QuoteBundleQuery.Data.RedeemedCampaign

    func refetch() {
        client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).onValue { _ in }
    }

    private func updateCacheRedeemedCampaigns(
        campaigns: [Campaign]
    ) {
        self.store.update(query: self.query) { (storeData: inout GraphQL.QuoteBundleQuery.Data) in
            storeData.redeemedCampaigns = campaigns
        }

        self.refetch()
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
                    return Future(error: UpdateRedeemedCampaigns.failed)
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

    func updateStartDate(quoteId: String, date: Date?) -> Future<Date?> {
        guard let date = date else {
            return self.client
                .perform(
                    mutation: GraphQL.RemoveStartDateMutation(id: quoteId)
                )
                .flatMap { data in
                    guard data.removeStartDate.asCompleteQuote?.startDate == nil else {
                        return Future(error: UpdateStartDateError.failed)
                    }

                    self.updateCacheStartDate(quoteId: quoteId, date: nil)
                    self.offerStore.send(.setStartDate(id: quoteId, startDate: date))

                    return Future(nil)
                }
        }

        return self.client
            .perform(
                mutation: GraphQL.ChangeStartDateMutation(
                    id: quoteId,
                    startDate: date.localDateString ?? ""
                )
            )
            .flatMap { data in
                guard let date = data.editQuote.asCompleteQuote?.startDate?.localDateToDate else {
                    return Future(error: UpdateStartDateError.failed)
                }

                self.updateCacheStartDate(
                    quoteId: quoteId,
                    date: data.editQuote.asCompleteQuote?.startDate
                )

                return Future(date)
            }
    }

    enum CheckoutUpdateError: Error {
        case failed
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
                    return Future(error: CheckoutUpdateError.failed)
                }

                return self.client
                    .fetch(
                        query: self.query,
                        cachePolicy: .fetchIgnoringCacheData
                    )
                    .toVoid()
            }
    }
}
