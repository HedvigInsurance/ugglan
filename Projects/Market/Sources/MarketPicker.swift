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
    
    @State var title: String = L10n.MarketLanguageScreen.title
    @State var buttonText: String = L10n.MarketLanguageScreen.continueButtonText
    
    enum ViewState {
        case loading
        case marketAndLanguage
        case onboardAndLogin
    }
    
    @State var viewState: ViewState = .loading

    public init() {
        ApplicationState.preserveState(.marketPicker)

        viewModel.fetchMarketingImage()
        viewModel.detectMarketFromLocation()
    }
    
    @ViewBuilder
    var marketAndLanguage: some View {
        Spacer()
        hText(title, style: .title1)
        Spacer()

        MarketRow()
        Divider()
        LanguageRow()

        Spacer()
            .frame(height: 36)
        
        Button {
            hAnalyticsEvent.marketSelected(
                locale: Localization.Locale.currentLocale.lprojCode
            )
            .send()

            hAnalyticsExperiment.load { _ in

            }
            
            withAnimation(.easeInOut) {
                viewState = .onboardAndLogin
            }
            
        } label: {
            hText(buttonText, style: .body)
                .foregroundColor(hLabelColor.primary.inverted)
                .frame(minWidth: 200, maxWidth: .infinity, minHeight: 52)
        }
        .background(Color.white)
        .cornerRadius(.defaultCornerRadius)
    }
    
    @ViewBuilder
    var onboardAndLogin: some View {
        Spacer()
        Image(uiImage: hCoreUIAssets.wordmarkWhite.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 40)
        Spacer()
        
        Button {
            hAnalyticsEvent.buttonClickMarketingOnboard().send()

//            store.send(.onboard)
            withAnimation(.easeInOut) {
                viewState = .marketAndLanguage
            }
            
        } label: {
            hText(L10n.marketingGetHedvig, style: .body)
                .foregroundColor(hLabelColor.primary.inverted)
                .frame(minWidth: 200, maxWidth: .infinity, minHeight: 52)
        }
        .background(Color.white)
        .cornerRadius(.defaultCornerRadius)
        
        hButton.LargeButtonOutlined {
            hAnalyticsEvent.buttonClickMarketingLogin().send()

            store.send(.loginButtonTapped)
        } content: {
            hText(L10n.marketingLogin)
        }
    }

    public var body: some View {
        VStack {
            switch viewState {
            case .loading:
                ZStack {}
            case .marketAndLanguage:
                marketAndLanguage
            case .onboardAndLogin:
                onboardAndLogin
            }
        }
        .environment(\.colorScheme, .dark)
        .padding(.horizontal, 16)
        .opacity(viewState == .loading ? 0 : 1)
        .background(
            ImageWithHashFallBack(
                imageURL: viewModel.imageURL,
                blurHash: viewModel.blurHash
            )
        )
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
                    self.viewState = .marketAndLanguage
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
