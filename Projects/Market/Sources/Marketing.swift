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

	public init() {}
}

extension Marketing: Presentable {
	public func materialize() -> (UIViewController, Disposable) {
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

		bag += client.fetch(query: GraphQL.MarketingImagesQuery()).compactMap {
			$0.appMarketingImages.filter { $0.language?.code == Localization.Locale.currentLocale.code }
				.first
		}.compactMap { $0 }.onValue { marketingImage in
			guard let url = URL(string: marketingImage.image?.url ?? "") else { return }

			let blurImage = UIImage(
				blurHash: marketingImage.blurhash ?? "",
				size: .init(width: 32, height: 32)
			)
			imageView.image = blurImage

			imageView.contentMode = .scaleAspectFill
			imageView.kf.setImage(with: url, placeholder: blurImage, options: [.transition(.fade(0.25))])
		}

		let contentStackView = UIStackView()
		contentStackView.axis = .vertical
		contentStackView.spacing = 15
		contentStackView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 10)
		contentStackView.isLayoutMarginsRelativeArrangement = true

		containerView.addSubview(contentStackView)

		contentStackView.snp.makeConstraints { make in make.bottom.trailing.leading.equalToSuperview() }

		let onboardButton = Button(
			title: L10n.marketingGetHedvig,
			type: .standard(backgroundColor: .white, textColor: .black)
		)

		bag += onboardButton.onTapSignal.onValue { _ in
			if #available(iOS 13.0, *) {
				viewController.navigationController?.navigationBar.overrideUserInterfaceStyle =
					.unspecified
			} else {
				viewController.navigationController?.navigationBar.barStyle = .default
			}

			CrossFramework.presentOnboarding(viewController)
		}

		bag += contentStackView.addArranged(onboardButton) { buttonView in buttonView.hero.id = "ContinueButton"
			buttonView.hero.modifiers = [.spring(stiffness: 400, damping: 100)]
		}

		let loginButton = Button(
			title: L10n.marketingLogin,
			type: .standardOutline(borderColor: .white, textColor: .white)
		)

		bag += loginButton.onTapSignal.onValue { _ in CrossFramework.presentLogin(viewController) }

		bag += contentStackView.addArranged(loginButton)

		return (viewController, bag)
	}
}
