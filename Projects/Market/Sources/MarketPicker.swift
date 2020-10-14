import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Hero
import hGraphQL
import Mixpanel
import Presentation
import UIKit

public struct MarketPicker {
    @Inject var client: ApolloClient
    var didFinish: () -> Void

    public init(didFinish: @escaping () -> Void = {}) {
        self.didFinish = didFinish
    }
}

extension MarketPicker: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            DefaultStyling.applyCommonNavigationBarStyling(appearance)
            appearance.configureWithTransparentBackground()
            viewController.navigationItem.standardAppearance = appearance
            viewController.navigationItem.compactAppearance = appearance
        }

        let bag = DisposeBag()

        ApplicationState.preserveState(.marketPicker)

        let backgroundImageView = UIImageView()

        bag += client.fetch(query: GraphQL.MarketingImagesQuery())
            .compactMap { $0.appMarketingImages.filter { $0?.language?.code == Localization.Locale.currentLocale.code }.first }
            .compactMap { $0 }
            .onValue { marketingImage in
                guard let url = URL(string: marketingImage.image?.url ?? "") else {
                    return
                }

                let blurImage = UIImage(blurHash: marketingImage.blurhash ?? "", size: .init(width: 32, height: 32))
                backgroundImageView.image = blurImage

                backgroundImageView.contentMode = .scaleAspectFill
                backgroundImageView.kf.setImage(
                    with: url,
                    placeholder: blurImage,
                    options: [
                        .transition(.fade(0.25)),
                    ]
                )
            }

        let form = FormView()
        let view = UIView()

        bag += view.windowSignal.onFirstValue { _ in
            if #available(iOS 13.0, *) {
                viewController.navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
            } else {
                viewController.navigationController?.navigationBar.barStyle = .black
            }
        }

        viewController.view = view
        view.addSubview(backgroundImageView)

        backgroundImageView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        view.addSubview(form)

        let welcomeLabel = UILabel(
            value: L10n.MarketLanguageScreen.title,
            style: .brand(.title1(color: .primary(state: .negative)))
        )
        view.addSubview(welcomeLabel)

        welcomeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        form.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }

        let pickedMarketSignal: ReadWriteSignal<Market> = ReadWriteSignal(.sweden)

        form.transform = CGAffineTransform(translationX: 0, y: 100)
        form.alpha = 0

        bag += client.fetch(query: GraphQL.GeoQuery()).valueSignal.compactMap { $0.geo.countryIsoCode }.onValue { countryISOCode in
            switch countryISOCode {
            case "SE":
                pickedMarketSignal.value = .sweden
            case "NO":
                pickedMarketSignal.value = .norway
            default:
                pickedMarketSignal.value = .sweden
            }

            Localization.Locale.currentLocale = pickedMarketSignal.value.preferredLanguage

            let section = form.appendSection()
            if #available(iOS 13.0, *) {
                section.overrideUserInterfaceStyle = .dark
            }

            let marketRow = MarketRow(market: pickedMarketSignal.value)
            bag += section.append(marketRow)

            bag += marketRow.$market.onValue { newMarket in
                Localization.Locale.currentLocale = newMarket.preferredLanguage
            }

            let languageRow = LanguageRow(currentMarket: pickedMarketSignal.value)
            bag += section.append(languageRow)
            bag += marketRow.$market.bindTo(languageRow.$currentMarket)

            bag += form.append(Spacing(height: 36))

            let continueButton = Button(
                title: L10n.MarketLanguageScreen.continueButtonText,
                type: .standard(backgroundColor: .white, textColor: .black)
            )
            bag += form.append(continueButton.insetted(UIEdgeInsets(horizontalInset: 15, verticalInset: 0)) { buttonView in
                buttonView.hero.id = "ContinueButton"
                buttonView.hero.modifiers = [.spring(stiffness: 400, damping: 100)]
            })

            bag += continueButton.onTapSignal.onValue {
                guard let navigationController = viewController.navigationController else {
                    return
                }

                if navigationController.hero.isEnabled {
                    navigationController.hero.isEnabled = false
                }

                navigationController.hero.isEnabled = true
                navigationController.hero.navigationAnimationType = .fade
                viewController.present(Marketing())
            }

            bag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce()
                .delay(by: 1.25)
                .take(first: 1)
                .animated(style: .lightBounce(duration: 0.75), animations: { _ in
                    form.transform = CGAffineTransform.identity
                    form.alpha = 1
                    form.layoutIfNeeded()
            })
        }

        bag += form.didMoveToWindowSignal.onValue {
            ContextGradient.currentOption = .none
        }

        return (viewController, bag)
    }
}
