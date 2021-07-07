//
//  OfferState.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-07-07.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Apollo
import Flow
import hCore
import hGraphQL

class OfferState {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
    let ids: [String]

    public init(
        ids: [String]
    ) {
        self.ids = ids
    }

    private var bag = DisposeBag()
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

    private func updateCacheRedeemedCampaigns(
        cost: GraphQL.CostFragment,
        campaigns: [Campaign]
    ) {
        self.store.update(query: self.query) { (storeData: inout GraphQL.QuoteBundleQuery.Data) in
            storeData.redeemedCampaigns = campaigns
            storeData.quoteBundle.bundleCost.fragments.costFragment = cost
        }
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
                guard let campaigns = data.redeemCodeV2.asSuccessfulRedeemResult?.campaigns,
                    let cost = data.redeemCodeV2.asSuccessfulRedeemResult?.cost
                else {
                    return Future(error: UpdateRedeemedCampaigns.failed)
                }

                let mappedCampaigns = campaigns.map { campaign in
                    Campaign.init(
                        displayValue: campaign.displayValue
                    )
                }

                self.updateCacheRedeemedCampaigns(
                    cost: cost.fragments.costFragment,
                    campaigns: mappedCampaigns
                )

                return Future()
            }
    }

    func removeRedeemedCampaigns() -> Future<Void> {
        return self.client.perform(mutation: GraphQL.RemoveDiscountMutation())
            .flatMap { data in
                let cost = data.removeDiscountCode.cost
                self.updateCacheRedeemedCampaigns(cost: cost.fragments.costFragment, campaigns: [])
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

    enum SignEvent {
        case swedishBankId(
            autoStartToken: String,
            subscription: CoreSignal<Plain, GraphQL.SignStatusSubscription.Data>
        )
        case simpleSign(subscription: CoreSignal<Plain, GraphQL.SignStatusSubscription.Data>)
        case done
        case failed
    }

    func signQuotes() -> Future<SignEvent> {
        let subscription = signStatusSubscription

        bag += subscription.map { $0.signStatus?.status?.signState == .completed }.filter(predicate: { $0 })
            .distinct()
            .onValue({ _ in
                self.$hasSignedQuotes.value = true
            })
        
        return dataSignal.map { $0.signMethodForQuotes }.mapLatestToFuture { signMethod in
            switch signMethod {
            case .approveOnly:
                return self.client.perform(mutation: GraphQL.ApproveQuotesMutation(ids: self.ids)).map { data in
                    if data.approveQuotes == true {
                        self.$hasSignedQuotes.value = true
                        return SignEvent.done
                    }
                    
                    return SignEvent.failed
                }
            default:
                return self.client.perform(mutation: GraphQL.SignQuotesMutation(ids: self.ids))
                    .map { data in
                        if data.signQuotes.asFailedToStartSign != nil {
                            return SignEvent.failed
                        } else if let session = data.signQuotes.asSwedishBankIdSession {
                            return SignEvent.swedishBankId(
                                autoStartToken: session.autoStartToken ?? "",
                                subscription: subscription
                            )
                        } else if data.signQuotes.asSimpleSignSession != nil {
                            return SignEvent.simpleSign(subscription: subscription)
                        }

                        return SignEvent.failed
                    }
            }
        }.future
    }
}
