import Apollo
import Foundation
import hGraphQL

extension QuoteBundle {
    func quoteFor(id: String?) -> QuoteBundle.Quote? {
        self.quotes.first { quote in
            quote.id == id
        }
    }
}
