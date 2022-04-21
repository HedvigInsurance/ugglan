import Apollo
import Flow
import Foundation
import hCore
import hGraphQL

extension OfferStore {
    internal func readyQuoteCartForSigning(quoteCartId: String, ids: [String]) -> FiniteSignal<OfferAction>? {
        return self.client
            .perform(
                mutation: GraphQL.SignQuoteCartMutation(
                    quoteCartId: quoteCartId,
                    quoteIds: ids,
                    locale: Localization.Locale.currentLocale.asGraphQLLocale()
                )
            )
            .compactMap { data in
                data.quoteCartStartCheckout.fragments.quoteCartFragment
            }
            .map {
                .setQuoteCart(quoteCart: .init(quoteCart: $0))
            }
            .valueThenEndSignal
    }

    internal func updateStartDatesQuoteCart(
        id: String,
        date: Date?,
        currentVariant: QuoteVariant?
    ) -> FiniteSignal<OfferAction>? {
        let jsonEncoder = JSONEncoder()
        let payload = QuoteCartPayload(startDate: date?.localDateString)
        guard let quoteVariant = currentVariant, let data = try? jsonEncoder.encode(payload),
            let encodedString = String(data: data, encoding: .utf8)
        else { return nil }

        let mutation = GraphQL.QuoteCartEditQuoteMutation(
            quoteCartId: id,
            quoteId: quoteVariant.id,
            payload: encodedString,
            locale: Localization.Locale.currentLocale.asGraphQLLocale()
        )
        return self.client.perform(mutation: mutation)
            .compactMap { data in
                return data.quoteCartEditQuote.asQuoteCart?.fragments.quoteCartFragment
            }
            .map { quoteCart in
                .setQuoteCart(quoteCart: .init(quoteCart: quoteCart))
            }
            .mapError { error in
                .failed(event: .updateStartDate)
            }
            .valueSignal
    }

    internal func quoteCartSignQuotesEffectPoll(
        quoteCartId: String,
        shouldFinish: ReadSignal<Bool>
    ) -> FiniteSignal<OfferAction>? {
        return Signal(every: 1, delay: 0.5)
            .map { _ in
                OfferAction.refetch
            }
            .finite()
            .take(until: shouldFinish)
    }
}

struct QuoteCartPayload: Codable {
    var startDate: String?
    var data: Data

    init(
        startDate: String?
    ) {
        self.startDate = startDate
        data = .init(startDate: startDate)
    }
}

struct Data: Codable {
    var startDate: String?
}
