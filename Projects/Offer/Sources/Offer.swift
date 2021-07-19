import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public enum OfferOption {
	case menuToTrailing
	case shouldPreserveState
}

public struct Offer {
	@Inject var client: ApolloClient
	let offerIDContainer: OfferIDContainer
	let menu: Menu?
	let state: OldOfferState
	let options: Set<OfferOption>

	public init(
		offerIDContainer: OfferIDContainer,
		menu: Menu?,
		options: Set<OfferOption> = []
	) {
		self.offerIDContainer = offerIDContainer
		self.menu = menu
		self.options = options
		self.state = OldOfferState(ids: offerIDContainer.ids)
	}
}

public enum OfferResult {
	case signed
	case close
	case chat
}

extension Offer: Presentable {
	public func materialize() -> (UIViewController, FiniteSignal<OfferResult>) {
		let viewController = UIViewController()

		if options.contains(.shouldPreserveState) {
			ApplicationState.preserveState(.offer)
		}

		Dependencies.shared.add(
			module: Module {
				return state
			}
		)

		if #available(iOS 13.0, *) {
			let appearance = UINavigationBarAppearance()
			appearance.configureWithTransparentBackground()
			DefaultStyling.applyCommonNavigationBarStyling(appearance)
			viewController.navigationItem.standardAppearance = appearance
			viewController.navigationItem.compactAppearance = appearance
		}

		let bag = DisposeBag()
		bag += state.dataSignal.compactMap { $0.quoteBundle.appConfiguration.title }
			.wait(until: state.isLoadingSignal.map { !$0 })
			.distinct()
			.delay(by: 0.1)
			.onValue { title in
				viewController.navigationItem.titleView = nil
				viewController.title = nil

				if let navigationBar = viewController.navigationController?.navigationBar,
					navigationBar.layer.animation(forKey: "fadeText") == nil
				{

					let fadeTextAnimation = CATransition()
					fadeTextAnimation.duration = 0.25
					fadeTextAnimation.type = .fade
					fadeTextAnimation.fillMode = .both

					navigationBar.layer
						.add(fadeTextAnimation, forKey: "fadeText")
				}

				switch title {
				case .logo:
					viewController.navigationItem.titleView = .titleWordmarkView
				case .updateSummary:
					viewController.title = L10n.offerUpdateSummaryTitle
				case .__unknown(_):
					break
				}
			}

		let optionsOrCloseButton = UIBarButtonItem(
			image: hCoreUIAssets.menuIcon.image,
			style: .plain,
			target: nil,
			action: nil
		)

		if options.contains(.menuToTrailing) {
			viewController.navigationItem.rightBarButtonItem = optionsOrCloseButton
		} else {
			viewController.navigationItem.leftBarButtonItem = optionsOrCloseButton
		}

		let scrollView = FormScrollView(
			frame: .zero,
			appliesGradient: false
		)
		scrollView.backgroundColor = .brand(.primaryBackground())

		let form = FormView()
		form.allowTouchesOfViewsOutsideBounds = true
		form.dynamicStyle = DynamicFormStyle { _ in
			.init(insets: .zero)
		}
		bag += viewController.install(form, scrollView: scrollView)

		bag += form.append(Header(scrollView: scrollView))
		bag += form.append(MainContentForm(scrollView: scrollView))

		let navigationBarBackgroundView = UIView()
		navigationBarBackgroundView.backgroundColor = .brand(.secondaryBackground())
		navigationBarBackgroundView.alpha = 0
		scrollView.addSubview(navigationBarBackgroundView)

		navigationBarBackgroundView.snp.makeConstraints { make in
			make.top.equalTo(scrollView.frameLayoutGuide.snp.top)
			make.width.equalToSuperview()
			make.height.equalTo(0)
		}

		let navigationBarBorderView = UIView()
		navigationBarBorderView.backgroundColor = .brand(.primaryBorderColor)
		navigationBarBackgroundView.addSubview(navigationBarBorderView)

		navigationBarBorderView.snp.makeConstraints { make in
			make.width.equalToSuperview()
			make.bottom.equalToSuperview()
			make.height.equalTo(CGFloat.hairlineWidth)
		}

		bag += scrollView.signal(for: \.contentOffset)
			.atOnce()
			.onValue { contentOffset in
				navigationBarBackgroundView.alpha =
					(contentOffset.y + scrollView.safeAreaInsets.top) / (Header.insetTop)
				navigationBarBackgroundView.snp.updateConstraints { make in
					if let navigationBar = viewController.navigationController?.navigationBar,
						let insetTop = viewController.navigationController?.view.safeAreaInsets
							.top
					{
						make.height.equalTo(navigationBar.frame.height + insetTop)
					}
				}
			}

		bag += state.$hasSignedQuotes.filter(predicate: { $0 }).flatMapLatest { _ in state.dataSignal }
			.onValue { data in
				Analytics.track(
					"QUOTES_SIGNED",
					properties: [
						"quoteIds": data.quoteBundle.quotes.map { $0.id }
					]
				)
			}

		return (
			viewController,
			FiniteSignal { callback in
				let store: OfferStore = self.get()

				bag += store.map { $0.chatOpened }.filter(predicate: { $0 }).distinct()
					.onValue({ _ in
						callback(.value(.signed))
					})

				bag += store.map { $0.chatOpened }.filter(predicate: { $0 }).distinct()
					.onValue { _ in
						callback(.value(.chat))
						store.send(.closeChat)
					}

				if let menu = menu {
					bag += optionsOrCloseButton.attachSinglePressMenu(
						viewController: viewController,
						menu: menu
					)
				} else {
					optionsOrCloseButton.image = hCoreUIAssets.close.image
					bag += optionsOrCloseButton.onValue {
						callback(.value(.close))
					}
				}

				return DelayedDisposer(bag, delay: 2)
			}
		)
	}
}
