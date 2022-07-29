import Apollo
import Flow
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct Marketing: View {
    @PresentableStore var store: MarketStore
    @ObservedObject var viewModel = MarketingViewModel()

    public init() {
        viewModel.fetchMarketingImage()
    }

    public var body: some View {
        VStack {
            Spacer()
            Image(uiImage: hCoreUIAssets.wordmarkWhite.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 40)
            Spacer()

            hButton.LargeButtonFilled {
                hAnalyticsEvent.buttonClickMarketingOnboard().send()

                store.send(.onboard)
            } content: {
                hText(L10n.marketingGetHedvig)
            }

            hButton.LargeButtonOutlined {
                hAnalyticsEvent.buttonClickMarketingLogin().send()

                store.send(.loginButtonTapped)
            } content: {
                hText(L10n.marketingLogin)
            }
        }
        .padding(.horizontal, 16)
        .background(
            ImageWithHashFallBack(
                imageURL: viewModel.imageURL,
                blurHash: viewModel.blurHash
            )
        )
        .preferredColorScheme(.dark)
        .trackOnAppear(hAnalyticsEvent.screenView(screen: .marketing))
    }
}

class MarketingViewModel: ObservableObject {
    @Inject var client: ApolloClient
    @Published var blurHash: String = ""
    @Published var imageURL: String = ""

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
}

struct Marketing_Previews: PreviewProvider {
    static var previews: some View {
        Marketing()
    }
}
