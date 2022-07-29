import SwiftUI
import hAnalytics
import hCore
import hCoreUI

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

        Spacer().frame(height: 36)

        Button {
            hAnalyticsEvent.marketSelected(
                locale: Localization.Locale.currentLocale.lprojCode
            )
            .send()
            hAnalyticsExperiment.load { _ in }

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
            store.send(.onboard)
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
                    .navigationBarItems(
                        leading: Button(action: {
                            withAnimation(.easeInOut) {
                                viewState = .marketAndLanguage
                            }
                        }) {
                            Image(uiImage: hCoreUIAssets.backButton.image)
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
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.viewState = .marketAndLanguage
                }
            }
        }
    }
}
