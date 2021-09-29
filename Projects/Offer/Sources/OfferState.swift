import Apollo
import Flow
import Foundation
import hCore
import hGraphQL
//
//class OldOfferState {
//    @PresentableStore var offerStore: OfferStore

//    private func updateCacheStartDate(quoteId: String, date: String?) {
//        self.store.update(query: self.query) {
//            (storeData: inout GraphQL.QuoteBundleQuery.Data) in
//            storeData.quoteBundle.inception.asConcurrentInception?.startDate = date
//
//            guard let allInceptions = storeData.quoteBundle.inception.asIndependentInceptions?.inceptions
//            else {
//                return
//            }
//
//            typealias Inception = GraphQL.QuoteBundleQuery.Data.QuoteBundle.Inception
//                .AsIndependentInceptions.Inception
//
//            let updatedInceptions = allInceptions.map { inception -> Inception in
//                guard inception.correspondingQuote.asCompleteQuote?.id == quoteId else {
//                    return inception
//                }
//                var inception = inception
//                inception.startDate = date
//                return inception
//            }
//
//            storeData.quoteBundle.inception.asIndependentInceptions?.inceptions = updatedInceptions
//        }
//    }
