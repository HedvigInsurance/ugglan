import SwiftUI
import hAnalytics
import hCore
import hCoreUI

public struct MarketPickerView: View {
    var onLoad: () -> Void

    @ObservedObject var viewModel = MarketPickerViewModel()
    @PresentableStore var store: MarketStore
    @State var submitButtonLoading: Bool = false

    @State var title: String = L10n.MarketLanguageScreen.title
    @State var buttonText: String = L10n.MarketLanguageScreen.continueButtonText

    enum ViewState {
        case loading
        case marketAndLanguage
        case onboardAndLogin
    }

    @State var viewState: ViewState = .loading

    public init(
        onLoad: @escaping () -> Void
    ) {
        self.onLoad = onLoad
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

        Spacer().frame(height: 36)

        hButton.LargeButtonPrimary {
            hAnalyticsEvent.marketSelected(
                locale: Localization.Locale.currentLocale.lprojCode
            )
            .send()

            withAnimation(.default) {
                submitButtonLoading = true
            }

            hAnalyticsExperiment.retryingLoad { _ in
                withAnimation(.default.delay(0.5)) {
                    submitButtonLoading = false
                }

                withAnimation(.easeInOut.delay(0.25)) {
                    viewState = .onboardAndLogin
                }
            }
        } content: {
            hText(buttonText, style: .body)
        }
        .hButtonIsLoading(submitButtonLoading)
        .hButtonFilledStyle(.overImage)
    }

    @ViewBuilder
    var onboardAndLogin: some View {
        Spacer()
        Image(uiImage: hCoreUIAssets.wordmarkWhite.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 40)
        Spacer()

        hButton.LargeButtonPrimary {
            hAnalyticsEvent.buttonClickMarketingLogin().send()
            store.send(.loginButtonTapped)
        } content: {
            HStack {
                Image(uiImage: hCoreUIAssets.bankIdLogo.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 16, height: 16)
                hText(L10n.marketingLogin)
            }
        }

        if store.state.market.showGetQuote {
            hButton.LargeButtonGhost {
                hAnalyticsEvent.buttonClickMarketingOnboard().send()
                store.send(.onboard)
            } content: {
                hText(L10n.marketingGetHedvig, style: .body)
            }
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
                    .navigationBarItems(
                        leading: Button(action: {
                            withAnimation(.easeInOut) {
                                viewState = .marketAndLanguage
                            }
                        }) {
                            Image(uiImage: hCoreUIAssets.arrowBack.image)
                                .resizable()
                                .foregroundColor(hLabelColor.primary)
                        }
                    )
            }
        }
        .environment(\.colorScheme, .dark)
        .padding(.horizontal, 16)
        .opacity(viewState == .loading ? 0 : 1)
        .modifier(
            ImageWithHashFallBack(
                imageURL: URL(string: viewModel.imageURL),
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
                self.viewState = .marketAndLanguage
                onLoad()
            }
        }
    }
}
