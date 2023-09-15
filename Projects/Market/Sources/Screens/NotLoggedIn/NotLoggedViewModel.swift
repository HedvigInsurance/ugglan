import Apollo
import Combine
import Flow
import Kingfisher
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hGraphQL

public class NotLoggedViewModel: ObservableObject {
    @Inject var giraffe: hGiraffe
    @Published var blurHash: String = ""
    @Published var imageURL: String = ""
    @Published var bootStrapped: Bool = false
    @Published var locale: Localization.Locale = .currentLocale
    @Published var title: String = L10n.MarketLanguageScreen.title
    @Published var buttonText: String = L10n.MarketLanguageScreen.continueButtonText
    @Published var viewState: ViewState = .loading

    var onLoad: () -> Void = {}
    var cancellables = Set<AnyCancellable>()
    let bag = DisposeBag()

    init() {
        ApplicationState.preserveState(.notLoggedIn)
        Localization.Locale.$currentLocale
            .distinct()
            .plain()
            .delay(by: 0.1)
            .publisher
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.title = L10n.MarketLanguageScreen.title
                self?.buttonText = L10n.MarketLanguageScreen.continueButtonText
            }
            .store(in: &cancellables)

        $bootStrapped
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                if value {
                    hAnalyticsEvent.screenView(screen: .marketPicker).send()
                    self?.viewState = .marketAndLanguage
                    self?.onLoad()
                }
            }
            .store(in: &cancellables)
        detectMarketFromLocation()
    }

    func detectMarketFromLocation() {
        let store: MarketStore = globalPresentableStoreContainer.get()
        bag += giraffe.client
            .fetch(
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

    enum ViewState {
        case loading
        case marketAndLanguage
    }
}
