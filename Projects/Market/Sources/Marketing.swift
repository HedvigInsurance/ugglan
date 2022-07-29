import Apollo
import Flow
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public class MarketPickerViewModel: ObservableObject {
    @Inject var client: ApolloClient
    @Published var blurHash: String = ""
    @Published var imageURL: String = ""
    @Published var bootStrapped: Bool = false

    let bag = DisposeBag()

    func fetchMarketingImage() {
        bag +=
            client.fetch(
                query: GraphQL.MarketingImagesQuery()
            )
            .compactMap {
                $0.appMarketingImages
                    .filter { $0.language?.code == Localization.Locale.currentLocale.code }.first
            }
            .compactMap { $0 }
            .onValue {
                if let blurHash = $0.blurhash, let imageURL = $0.image?.url {
                    self.blurHash = blurHash
                    self.imageURL = imageURL
                }
            }
    }

    func detectMarketFromLocation() {
        let store: MarketStore = globalPresentableStoreContainer.get()
        let innerBag = bag.innerBag()
        bag += client.fetch(query: GraphQL.GeoQuery(), queue: .global(qos: .background))
            .valueSignal
            .map { $0.geo.countryIsoCode.lowercased() }
            .map { code -> Market in
                guard
                    let bestMatch = Market.activatedMarkets
                        .flatMap({ market in
                            market.languages
                        })
                        .first(where: { locale -> Bool in
                            locale.rawValue.lowercased().contains(code)
                        })
                else {
                    return .sweden
                }

                return Market(rawValue: bestMatch.market.rawValue)!
            }
            .atValue(on: .main) { market in
                store.send(.selectMarket(market: market))
                innerBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce()
                    .delay(by: 1.25)
                    .take(first: 1)
                    .map { _ in
                        self.bootStrapped = true
                    }
            }
            .onError(on: .main) { _ in
                store.send(.selectMarket(market: .sweden))
                innerBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce()
                    .delay(by: 1.25)
                    .take(first: 1)
                    .map { _ in
                        self.bootStrapped = true
                    }
            }
    }
}
