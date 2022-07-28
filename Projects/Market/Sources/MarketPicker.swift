import Apollo
import Flow
import Form
import Foundation
import Hero
import Kingfisher
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL
import SwiftUI

public struct MarketPicker {
    @Inject var client: ApolloClient
    public init() {}
}

extension MarketPicker: Presentable {
    public func materialize() -> (UIViewController, Signal<Void>) {
        let viewController = UIViewController()

        let appearance = UINavigationBarAppearance()
        DefaultStyling.applyCommonNavigationBarStyling(appearance)
        appearance.configureWithTransparentBackground()
        viewController.navigationItem.standardAppearance = appearance
        viewController.navigationItem.compactAppearance = appearance

        let bag = DisposeBag()

        ApplicationState.preserveState(.marketPicker)

        let backgroundImageView = UIImageView()

        bag += client.fetch(query: GraphQL.MarketingImagesQuery())
            .compactMap {
                $0.appMarketingImages
                    .filter { $0.language?.code == Localization.Locale.currentLocale.code }.first
            }
            .compactMap { $0 }
            .onValue { marketingImage in
                guard let url = URL(string: marketingImage.image?.url ?? "") else { return }

                let blurImage = UIImage(
                    blurHash: marketingImage.blurhash ?? "",
                    size: .init(width: 32, height: 32)
                )
                backgroundImageView.image = blurImage

                backgroundImageView.contentMode = .scaleAspectFill
                backgroundImageView.kf.setImage(
                    with: url,
                    placeholder: blurImage,
                    options: [.transition(.fade(0.25))]
                )
            }

        let form = FormView()
        let view = UIView()

        bag += view.windowSignal.onFirstValue { _ in
            viewController.navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
        }

        viewController.view = view
        view.addSubview(backgroundImageView)

        backgroundImageView.snp.makeConstraints { make in make.top.bottom.trailing.leading.equalToSuperview() }

        view.addSubview(form)

        let localeUpdatedSignal = Localization.Locale.$currentLocale.atOnce().delay(by: 0)

        let welcomeLabel = UILabel(value: "", style: .brand(.title1(color: .primary(state: .negative))))
        view.addSubview(welcomeLabel)

        bag += localeUpdatedSignal.transition(style: .crossDissolve(duration: 0.25), with: welcomeLabel) { _ in
            welcomeLabel.value = L10n.MarketLanguageScreen.title
        }

        bag += welcomeLabel.traitCollectionSignal.atOnce()
            .onValue { traitCollection in
                welcomeLabel.snp.remakeConstraints { make in
                    if traitCollection.verticalSizeClass == .compact {
                        make.centerX.equalToSuperview()
                        make.top.equalToSuperview().offset(50)
                    } else {
                        make.center.equalToSuperview()
                    }
                }
            }

        form.snp.makeConstraints { make in make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }

        let store: MarketStore = get()

        form.transform = CGAffineTransform(translationX: 0, y: 100)
        form.alpha = 0

        bag += form.didMoveToWindowSignal.onValue { ContextGradient.currentOption = .none }

        bag += store.stateSignal.atOnce()
            .onValue { state in
                print(state)
            }

        return (
            viewController,
            Signal { callback in
                func renderMarketPicker() {
                    let section = form.appendSection()
                    section.overrideUserInterfaceStyle = .dark

                    let marketRow = HostingView(rootView: MarketRowView())
                    section.append(marketRow)

                    let languageRow = HostingView(rootView: LanguageRowView())
                    section.append(languageRow)

                    bag += form.append(Spacing(height: 36))

                    let continueButton = Button(
                        title: "",
                        type: .standard(backgroundColor: .white, textColor: .black)
                    )
                    bag += form.append(
                        continueButton.insetted(
                            UIEdgeInsets(horizontalInset: 15, verticalInset: 0)
                        ) {
                            buttonView in buttonView.hero.id = "ContinueButton"
                            buttonView.hero.modifiers = [
                                .spring(stiffness: 400, damping: 100)
                            ]

                            bag += localeUpdatedSignal.atOnce()
                                .transition(
                                    style: .crossDissolve(duration: 0.25),
                                    with: buttonView
                                ) { _ in
                                    continueButton.title.value =
                                        L10n.MarketLanguageScreen
                                        .continueButtonText
                                }
                        }
                    )

                    bag += continueButton.onTapSignal.onValue {
                        guard
                            let navigationController = viewController
                                .navigationController
                        else {
                            return
                        }
                        if !UITraitCollection.isCatalyst {
                            navigationController.hero.isEnabled = true
                            navigationController.hero.navigationAnimationType =
                                .fade
                        }

                        hAnalyticsEvent.marketSelected(
                            locale: Localization.Locale.currentLocale.lprojCode
                        )
                        .send()

                        hAnalyticsExperiment.load { _ in
                            callback(())
                        }
                    }

                    bag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce()
                        .delay(by: 1.25)
                        .take(first: 1)
                        .animated(
                            style: .lightBounce(duration: 0.75),
                            animations: { _ in
                                form.transform = CGAffineTransform.identity
                                form.alpha = 1
                                form.layoutIfNeeded()

                                viewController.trackOnAppear(hAnalyticsEvent.screenView(screen: .marketPicker))
                            }
                        )
                }

                bag += client.fetch(query: GraphQL.GeoQuery()).valueSignal
                    .atValue { data in
                        if let bestMatchedLocale = Market.activatedMarkets.flatMap({ market in market.languages })
                            .first(where: {
                                locale -> Bool in
                                locale.rawValue.lowercased()
                                    .contains(data.geo.countryIsoCode.lowercased())
                            })
                        {
                            let locale = Localization.Locale(
                                rawValue: bestMatchedLocale.rawValue
                            )!
                            let market = Market(rawValue: locale.market.rawValue)!
                            store.send(.selectMarket(market: market))
                        } else {
                            store.send(.selectMarket(market: .sweden))
                        }

                        renderMarketPicker()
                    }
                    .onError { _ in
                        store.send(.selectMarket(market: .sweden))
                        renderMarketPicker()
                    }

                return bag
            }
        )
    }
}

public struct MarketPickerView: View {
    @ObservedObject var viewModel = MarketPickerViewModel()
    @PresentableStore var store: MarketStore
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var title: String = L10n.MarketLanguageScreen.title
    @State var buttonText: String = L10n.MarketLanguageScreen.continueButtonText
    
    public init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        ApplicationState.preserveState(.marketPicker)
        
        viewModel.fetchMarketingImage()
    }
    
    public var body: some View {
        hForm {
            if horizontalSizeClass == .compact {
                hText(title, style: .title1)
                    .padding(.top, 50)
                
                Spacer()
            } else {
                hText(title, style: .title1)
            }
        }
        .hFormAttachToBottom {
            VStack {
                MarketRowView()
                Divider()
                LanguageRowView()
                
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
            }
            .padding(.horizontal, 16)
        }
        .opacity(viewModel.show ? 1 : 0)
        .preferredColorScheme(.dark)
        .backgroundImageWithBlurHashFallback(
            imageURL: URL(string: viewModel.imageURL),
            blurHash: viewModel.blurHash
        )
        .transition(.opacity)
        .onReceive(Localization.Locale.$currentLocale.plain().publisher) { _ in
            self.title = L10n.MarketLanguageScreen.title
            self.buttonText = L10n.MarketLanguageScreen.continueButtonText
        }
    }
}

public class MarketPickerViewModel: ObservableObject {
    @Inject var client: ApolloClient
    @Published var blurHash: String = ""
    @Published var imageURL: String = ""
    @Published var show: Bool = false
    
    func fetchMarketingImage() {
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
                self.show = true
            }
        }
    }
}
