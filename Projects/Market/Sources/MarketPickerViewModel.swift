import Apollo
import Flow
import Kingfisher
import Presentation
import SwiftUI
import hCore
import hGraphQL

public class MarketPickerViewModel: ObservableObject {
    @Inject var giraffe: hGiraffe
    @Published var blurHash: String = ""
    @Published var imageURL: String = ""
    @Published var bootStrapped: Bool = false

    let bag = DisposeBag()

    func fetchMarketingImage() {
        bag += giraffe.client.fetch(
                query: GiraffeGraphQL.MarketingImagesQuery()
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

                    let prefetcher = ImagePrefetcher(urls: [URL(string: imageURL)!])
                    prefetcher.start()
                }
            }
    }

    func detectMarketFromLocation() {
        let store: MarketStore = globalPresentableStoreContainer.get()
        let innerBag = bag.innerBag()

        bag += giraffe.client.fetch(
            query: GiraffeGraphQL.GeoQuery(),
            queue: .global(qos: .background)
        )
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
                self.bootStrapped = true
            }
            .onError(on: .main) { _ in
                store.send(.selectMarket(market: .sweden))
                self.bootStrapped = true
            }
    }
}
