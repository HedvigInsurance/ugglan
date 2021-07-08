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

public enum OfferIDContainer {
	private static var storageKey = "OfferIDContainer"

	var ids: [String] {
		switch self {
		case .stored:
			return UserDefaults.standard.value(forKey: Self.storageKey) as? [String] ?? []
		case let .exact(ids, shouldStore):
			if shouldStore {
				UserDefaults.standard.set(ids, forKey: Self.storageKey)
			}

			return ids
		}
	}

	case stored
	case exact(ids: [String], shouldStore: Bool)
}

public struct Offer {
	@Inject var client: ApolloClient
	let offerIDContainer: OfferIDContainer
	let menu: Menu
	let state: OfferState
	let options: Set<OfferOption>

	public init(
		offerIDContainer: OfferIDContainer,
		menu: Menu,
		options: Set<OfferOption> = []
	) {
		self.offerIDContainer = offerIDContainer
		self.menu = menu
		self.options = options
		self.state = OfferState(ids: offerIDContainer.ids)
	}
}

extension GraphQL.QuoteBundleQuery.Data.QuoteBundle {
	func quoteFor(id: GraphQLID?) -> GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote? {
		self.quotes.first { quote in
			quote.id == id
		}
	}
}

class OfferState {
	@Inject var client: ApolloClient
	@Inject var store: ApolloStore
	let ids: [String]

	public init(
		ids: [String]
	) {
		self.ids = ids
	}

	private var bag = DisposeBag()
	@ReadWriteState var hasSignedQuotes = false

	lazy var isLoadingSignal: ReadSignal<Bool> = {
		return client.fetch(query: query).valueSignal.plain().map { _ in false }.delay(by: 0.5)
			.readable(initial: true)
	}()

	var query: GraphQL.QuoteBundleQuery {
		GraphQL.QuoteBundleQuery(ids: ids, locale: Localization.Locale.currentLocale.asGraphQLLocale())
	}

	var dataSignal: CoreSignal<Plain, GraphQL.QuoteBundleQuery.Data> {
		client.watch(query: query)
	}

	var quotesSignal: CoreSignal<Plain, [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote]> {
		dataSignal.map { $0.quoteBundle.quotes }
	}

	var signStatusSubscription: CoreSignal<Plain, GraphQL.SignStatusSubscription.Data> {
		client.subscribe(subscription: GraphQL.SignStatusSubscription())
	}

	enum UpdateStartDateError: Error {
		case failed
	}

	enum UpdateRedeemedCampaigns: Error {
		case failed
	}

	private func updateCacheStartDate(quoteId: String, date: String?) {
		self.store.update(query: self.query) {
			(storeData: inout GraphQL.QuoteBundleQuery.Data) in
			storeData.quoteBundle.inception.asConcurrentInception?.startDate = date

			guard let allInceptions = storeData.quoteBundle.inception.asIndependentInceptions?.inceptions
			else {
				return
			}

			typealias Inception = GraphQL.QuoteBundleQuery.Data.QuoteBundle.Inception
				.AsIndependentInceptions.Inception

			let updatedInceptions = allInceptions.map { inception -> Inception in
				guard inception.correspondingQuote.asCompleteQuote?.id == quoteId else {
					return inception
				}
				var inception = inception
				inception.startDate = date
				return inception
			}

			storeData.quoteBundle.inception.asIndependentInceptions?.inceptions = updatedInceptions
		}
	}

	typealias Campaign = GraphQL.QuoteBundleQuery.Data.RedeemedCampaign

	private func updateCacheRedeemedCampaigns(
		cost: GraphQL.CostFragment,
		campaigns: [Campaign]
	) {
		self.store.update(query: self.query) { (storeData: inout GraphQL.QuoteBundleQuery.Data) in
			storeData.redeemedCampaigns = campaigns
			storeData.quoteBundle.bundleCost.fragments.costFragment = cost
		}
	}

	func updateRedeemedCampaigns(discountCode: String) -> Future<Void> {
		return self.client
			.perform(
				mutation: GraphQL.RedeemDiscountCodeMutation(
					code: discountCode,
					locale: Localization.Locale.currentLocale.asGraphQLLocale()
				)
			)
			.flatMap { data in
				guard let campaigns = data.redeemCodeV2.asSuccessfulRedeemResult?.campaigns,
					let cost = data.redeemCodeV2.asSuccessfulRedeemResult?.cost
				else {
					return Future(error: UpdateRedeemedCampaigns.failed)
				}

				let mappedCampaigns = campaigns.map { campaign in
					Campaign.init(
						displayValue: campaign.displayValue
					)
				}

				self.updateCacheRedeemedCampaigns(
					cost: cost.fragments.costFragment,
					campaigns: mappedCampaigns
				)

				return Future()
			}
	}

	func removeRedeemedCampaigns() -> Future<Void> {
		return self.client.perform(mutation: GraphQL.RemoveDiscountMutation())
			.flatMap { data in
				let cost = data.removeDiscountCode.cost
				self.updateCacheRedeemedCampaigns(cost: cost.fragments.costFragment, campaigns: [])
				return Future()
			}
	}

	func updateStartDate(quoteId: String, date: Date?) -> Future<Date?> {
		guard let date = date else {
			return self.client
				.perform(
					mutation: GraphQL.RemoveStartDateMutation(id: quoteId)
				)
				.flatMap { data in
					guard data.removeStartDate.asCompleteQuote?.startDate == nil else {
						return Future(error: UpdateStartDateError.failed)
					}

					self.updateCacheStartDate(quoteId: quoteId, date: nil)

					return Future(nil)
				}
		}

		return self.client
			.perform(
				mutation: GraphQL.ChangeStartDateMutation(
					id: quoteId,
					startDate: date.localDateString ?? ""
				)
			)
			.flatMap { data in
				guard let date = data.editQuote.asCompleteQuote?.startDate?.localDateToDate else {
					return Future(error: UpdateStartDateError.failed)
				}

				self.updateCacheStartDate(
					quoteId: quoteId,
					date: data.editQuote.asCompleteQuote?.startDate
				)

				return Future(date)
			}
	}

	enum CheckoutUpdateError: Error {
		case failed
	}

	func checkoutUpdate(quoteId: String, email: String, ssn: String) -> Future<Void> {
		return self.client
			.perform(
				mutation: GraphQL.CheckoutUpdateMutation(quoteID: quoteId, email: email, ssn: ssn)
			)
			.flatMap { data in
				guard data.editQuote.asCompleteQuote?.email == email,
					data.editQuote.asCompleteQuote?.ssn == ssn
				else {
					return Future(error: CheckoutUpdateError.failed)
				}

				return self.client
					.fetch(
						query: self.query,
						cachePolicy: .fetchIgnoringCacheData
					)
					.toVoid()
			}
	}

	enum SignEvent {
		case swedishBankId(
			autoStartToken: String,
			subscription: CoreSignal<Plain, GraphQL.SignStatusSubscription.Data>
		)
		case simpleSign(subscription: CoreSignal<Plain, GraphQL.SignStatusSubscription.Data>)
		case done
		case failed
	}

	func signQuotes() -> Future<SignEvent> {
		let subscription = signStatusSubscription

		bag += subscription.map { $0.signStatus?.status?.signState == .completed }.filter(predicate: { $0 })
			.distinct()
			.onValue({ _ in
				self.$hasSignedQuotes.value = true
			})

		return client.perform(mutation: GraphQL.SignQuotesMutation(ids: ids))
			.map { data in
				if data.signQuotes.asAlreadyCompleted != nil {
					self.$hasSignedQuotes.value = true
					return SignEvent.done
				} else if data.signQuotes.asFailedToStartSign != nil {
					return SignEvent.failed
				} else if let session = data.signQuotes.asSwedishBankIdSession {
					return SignEvent.swedishBankId(
						autoStartToken: session.autoStartToken ?? "",
						subscription: subscription
					)
				} else if data.signQuotes.asSimpleSignSession != nil {
					return SignEvent.simpleSign(subscription: subscription)
				}

				return SignEvent.failed
			}
	}
}

extension Offer: Presentable {
	public func materialize() -> (UIViewController, Future<Void>) {
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

		let optionsButton = UIBarButtonItem(
			image: hCoreUIAssets.menuIcon.image,
			style: .plain,
			target: nil,
			action: nil
		)

		bag += optionsButton.attachSinglePressMenu(
			viewController: viewController,
			menu: menu
		)

		if options.contains(.menuToTrailing) {
			viewController.navigationItem.rightBarButtonItem = optionsButton
		} else {
			viewController.navigationItem.leftBarButtonItem = optionsButton
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
			Future { completion in
				bag += state.$hasSignedQuotes.filter(predicate: { $0 })
					.onValue({ _ in
						completion(.success)
					})

				return DelayedDisposer(bag, delay: 2)
			}
		)
	}
}
