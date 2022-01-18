import Apollo
import Flow
import Form
import Presentation
import SnapKit
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct Marketing {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
    @ReadWriteState var id: String? = nil

    public init() {}
}

public enum MarketingResult {
    case onboard(id: String?)
    case login
}

extension Marketing: Presentable {
    public func materialize() -> (UIViewController, Signal<MarketingResult>) {
        let viewController = UIViewController()

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            DefaultStyling.applyCommonNavigationBarStyling(appearance)
            appearance.configureWithTransparentBackground()
            viewController.navigationItem.standardAppearance = appearance
            viewController.navigationItem.compactAppearance = appearance
            viewController.navigationItem.scrollEdgeAppearance = appearance
        }

        let bag = DisposeBag()

        let containerView = UIView()
        containerView.clipsToBounds = true
        viewController.view = containerView

        bag += containerView.windowSignal.onFirstValue { _ in
            if #available(iOS 13.0, *) {
                viewController.navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
            } else {
                viewController.navigationController?.navigationBar.barStyle = .black
            }
        }

        let imageView = UIImageView()

        containerView.addSubview(imageView)

        imageView.snp.makeConstraints { make in make.top.bottom.leading.trailing.equalToSuperview() }

        let wordmarkImageView = UIImageView()
        wordmarkImageView.contentMode = .scaleAspectFill
        wordmarkImageView.image = hCoreUIAssets.wordmarkWhite.image
        containerView.addSubview(wordmarkImageView)

        wordmarkImageView.snp.makeConstraints { make in make.centerX.centerY.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(40)
        }

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
                imageView.image = blurImage

                imageView.contentMode = .scaleAspectFill
                imageView.kf.setImage(
                    with: url,
                    placeholder: blurImage,
                    options: [.transition(.fade(0.25))]
                )
            }
        
        bag += client.perform(
            mutation:
                GraphQL.CreateOnboardingQuoteCartMutation(
                    input: .init(
                        market: Localization.Locale.currentLocale.graphQLMarket,
                        locale: Localization.Locale.currentLocale.rawValue
                    )
                )
        ).onValue { data in
            self.$id.value = data.onboardingQuoteCartCreate.id.displayValue
        }

        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 15
        contentStackView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 10)
        contentStackView.isLayoutMarginsRelativeArrangement = true

        containerView.addSubview(contentStackView)

        contentStackView.snp.makeConstraints { make in make.bottom.trailing.leading.equalToSuperview() }

        return (
            viewController,
            Signal { callback in

                let onboardButton = Button(
                    title: L10n.marketingGetHedvig,
                    type: .standard(backgroundColor: .white, textColor: .black)
                )
                
                bag += $id.providedSignal.map { $0 != nil }.bindTo(onboardButton.isEnabled)
                
                bag += onboardButton.onTapSignal.onValue { _ in
                    if #available(iOS 13.0, *) {
                        viewController.navigationController?.navigationBar
                            .overrideUserInterfaceStyle =
                            .unspecified
                    } else {
                        viewController.navigationController?.navigationBar.barStyle = .default
                    }
                    if !UITraitCollection.isCatalyst {
                        viewController.navigationController?.hero.isEnabled = false
                    }

                    callback(.onboard(id: $id.value))
                }

                bag += contentStackView.addArranged(onboardButton) { buttonView in
                    buttonView.hero.id = "ContinueButton"
                    buttonView.hero.modifiers = [.spring(stiffness: 400, damping: 100)]
                }

                let loginButton = Button(
                    title: L10n.marketingLogin,
                    type: .standardOutline(borderColor: .white, textColor: .white)
                )

                bag += loginButton.onTapSignal.onValue { _ in
                    if !UITraitCollection.isCatalyst {
                        viewController.navigationController?.hero.isEnabled = false
                    }
                    callback(.login)
                }

                bag += contentStackView.addArranged(loginButton)

                return bag
            }
        )
    }
}

extension Localization.Locale {
    var graphQLMarket: GraphQL.Market {
        switch self.market {
        case .dk:
            return .denmark
        case .se:
            return .sweden
        case .no:
            return .norway
        default:
            return .__unknown("Unknown")
        }
    }
}
