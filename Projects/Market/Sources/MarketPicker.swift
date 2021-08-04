import Apollo
import Flow
import Form
import Foundation
import Hero
import Kingfisher
import Mixpanel
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct MarketPicker {
	@Inject var client: ApolloClient
	public init() {}
}

extension MarketPicker: Presentable {
	public func materialize() -> (UIViewController, Signal<Void>) {
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
			if #available(iOS 13.0, *) {
				viewController.navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
			} else {
				viewController.navigationController?.navigationBar.barStyle = .black
			}
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

		let pickedMarketSignal: ReadWriteSignal<Market> = ReadWriteSignal(.sweden)

		form.transform = CGAffineTransform(translationX: 0, y: 100)
		form.alpha = 0

		bag += form.didMoveToWindowSignal.onValue { ContextGradient.currentOption = .none }

		return (
			viewController,
			Signal { callback in
				bag += client.fetch(query: GraphQL.MarketQuery()).valueSignal
					.onValue { data in
						if let bestMatchedLocale = data.availableLocales.first(where: {
							locale -> Bool in
							locale.rawValue.lowercased()
								.contains(data.geo.countryIsoCode.lowercased())
						}) {
							let locale = Localization.Locale(
								rawValue: bestMatchedLocale.rawValue
							)!
							let market = Market(rawValue: locale.market.rawValue)!
							pickedMarketSignal.value = market
						} else {
							pickedMarketSignal.value = .sweden
						}

						Localization.Locale.currentLocale =
							pickedMarketSignal.value.preferredLanguage

						let section = form.appendSection()
						if #available(iOS 13.0, *) {
							section.overrideUserInterfaceStyle = .dark
						}

						let marketRow = MarketRow(
							market: pickedMarketSignal.value,
							availableLocales: data.availableLocales
						)
						bag += section.append(marketRow)

						bag += marketRow.$market.onValue { newMarket in
							Localization.Locale.currentLocale = newMarket.preferredLanguage
						}

						let languageRow = LanguageRow(currentMarket: pickedMarketSignal.value)
						bag += section.append(languageRow)
						bag += marketRow.$market.bindTo(languageRow.$currentMarket)

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
							callback(())
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
								}
							)
					}

				return bag
			}
		)
	}
}
