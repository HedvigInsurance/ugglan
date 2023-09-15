import SwiftUI
import hAnalytics
import hCore
import hCoreUI

public struct NotLoggedInView: View {
    var onLoad: () -> Void
    @ObservedObject var viewModel = NotLoggedViewModel()
    @PresentableStore var store: MarketStore

    @State var title: String = L10n.MarketLanguageScreen.title
    @State var buttonText: String = L10n.MarketLanguageScreen.continueButtonText

    enum ViewState {
        case loading
        case marketAndLanguage
    }
    @State var viewState: ViewState = .loading

    public init(
        onLoad: @escaping () -> Void
    ) {
        self.onLoad = onLoad
        ApplicationState.preserveState(.notLoggedIn)

        viewModel.fetchMarketingImage()
        viewModel.detectMarketFromLocation()
    }

    @ViewBuilder
    var marketAndLanguage: some View {
        ZStack {
            Image(uiImage: hCoreUIAssets.wordmark.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
                .offset(y: -24)
            VStack {
                HStack {
                    Spacer()
                    PresentableStoreLens(
                        MarketStore.self,
                        getter: { state in
                            state.market
                        }
                    ) { market in
                        Button {

                        } label: {
                            Image(uiImage: market.icon)
                                .padding(8)
                        }

                    }

                }
                Spacer()
                VStack {
                    hButton.LargeButton(type: .primary) {
                        store.send(.loginButtonTapped)
                    } content: {
                        hText(L10n.bankidLoginTitle)
                    }

                    hButton.LargeButton(type: .ghost) {
                        store.send(.onboard)
                    } content: {
                        hText(L10n.marketingGetHedvig)
                    }

                }
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
            }
        }
        .environment(\.colorScheme, .light)
        .padding(.horizontal, 16)
        .opacity(viewState == .loading ? 0 : 1)
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
        .background(
            LoginVideoView().ignoresSafeArea().animation(nil)
        )

    }

}

struct NotLoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        NotLoggedInView {

        }
    }
}
