import SwiftUI
import hCore
import hCoreUI

//public struct NotLoggedInView: View {
//    @ObservedObject var vm = NotLoggedViewModel()
//    public init(
//        onLoad: @escaping () -> Void
//    ) {
//        self.vm.onLoad = onLoad
//    }
//
//    @ViewBuilder
//    var marketAndLanguage: some View {
//        ZStack {
//            Image(uiImage: hCoreUIAssets.wordmark.image)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(height: 40)
//                .offset(y: -24)
//            VStack {
//                HStack {
//                    Spacer()
//                    PresentableStoreLens(
//                        MarketStore.self,
//                        getter: { state in
//                            state.market
//                        }
//                    ) { market in
//                        Button {
//                            vm.showLanguagePicker = true
//                        } label: {
//                            Image(uiImage: market.icon)
//                                .padding(8)
//                        }
//
//                    }
//
//                }
//                Spacer()
//                VStack {
//                    hButton.LargeButton(type: .primary) {
//                        vm.onLoginPressed()
//                    } content: {
//                        hText(L10n.bankidLoginTitle)
//                    }
//
//                    hButton.LargeButton(type: .ghost) {
//                        vm.onOnBoardPressed()
//                    } content: {
//                        hText(L10n.marketingGetHedvig)
//                    }
//
//                }
//            }
//        }
//        .detent(presented: $vm.showLanguagePicker, style: .height) {
//            LanguageAndMarketPickerView()
//                .navigationTitle(L10n.loginMarketPickerPreferences)
//                .embededInNavigation()
//
//        }
//    }
//
//    public var body: some View {
//        ZStack {
//            LoginVideoView().ignoresSafeArea()
//            hSection {
//                VStack {
//                    switch vm.viewState {
//                    case .loading:
//                        ZStack {}
//                    case .marketAndLanguage:
//                        marketAndLanguage
//                    }
//                }
//                .environment(\.colorScheme, .light)
//                .opacity(vm.viewState == .loading ? 0 : 1)
//            }
//            .sectionContainerStyle(.transparent)
//        }
//    }
//
//}
//
//struct NotLoggedInView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotLoggedInView {
//
//        }
//    }
//}
