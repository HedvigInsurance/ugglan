import SwiftUI
import hAnalytics
import hCore
import hCoreUI

public struct NotLoggedInView: View {
    @ObservedObject var vm = NotLoggedViewModel()

    public init(
        onLoad: @escaping () -> Void
    ) {
        self.vm.onLoad = onLoad
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
                            vm.onCountryPressed()
                        } label: {
                            Image(uiImage: market.icon)
                                .padding(8)
                        }

                    }

                }
                Spacer()
                VStack {
                    hButton.LargeButton(type: .primary) {
                        vm.onLoginPressed()
                    } content: {
                        hText(L10n.bankidLoginTitle)
                    }
                    .hButtonIsLoading(vm.loadingExperiments)

                    hButton.LargeButton(type: .ghost) {
                        vm.onOnBoardPressed()
                    } content: {
                        hText(L10n.marketingGetHedvig)
                    }

                }
            }
        }
    }

    public var body: some View {
        VStack {
            switch vm.viewState {
            case .loading:
                ZStack {}
            case .marketAndLanguage:
                marketAndLanguage
            }
        }
        .environment(\.colorScheme, .light)
        .padding(.horizontal, 16)
        .opacity(vm.viewState == .loading ? 0 : 1)
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
