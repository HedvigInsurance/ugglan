import Apollo
import Flow
import Foundation
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct MarketPickerView: View {
    @ObservedObject var viewModel = MarketPickerViewModel()
    @PresentableStore var store: MarketStore
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass

    @State var title: String = L10n.MarketLanguageScreen.title
    @State var buttonText: String = L10n.MarketLanguageScreen.continueButtonText
    @State var show: Bool = false

    public init() {
        ApplicationState.preserveState(.marketPicker)

        viewModel.fetchMarketingImage()
        viewModel.detectMarketFromLocation()
    }

    public var body: some View {
        VStack {
            Spacer()
            hText(title, style: .title1)
            Spacer()

            MarketRow()
            Divider()
            LanguageRow()

            Spacer()
                .frame(height: 36)

            hButton.LargeButtonFilled {
                hAnalyticsEvent.marketSelected(
                    locale: Localization.Locale.currentLocale.lprojCode
                )
                .send()

                hAnalyticsExperiment.load { _ in

                }

                store.send(.openMarketing)
            } content: {
                hText(buttonText)
            }
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 16)
        .opacity(show ? 1 : 0)
        .background(
            ImageWithHashFallBack(
                imageURL: viewModel.imageURL,
                blurHash: viewModel.blurHash
            )
        )
        .preferredColorScheme(.dark)
        .onReceive(
            Localization.Locale.$currentLocale
                .distinct()
                .plain()
                .delay(by: 0.1)
                .publisher
        ) { _ in
            self.title = L10n.MarketLanguageScreen.title
            self.buttonText = L10n.MarketLanguageScreen.continueButtonText
        }
        .onReceive(viewModel.$bootStrapped) { val in
            if val {
                hAnalyticsEvent.screenView(screen: .marketPicker).send()
                withAnimation(.easeInOut(duration: 0.75)) {
                    self.show = true
                }
            }
        }
    }
}

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
