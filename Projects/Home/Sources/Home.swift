import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct Home {
	public static var openClaimsHandler: (_ viewController: UIViewController) -> Void = { _ in }
	public static var openCallMeChatHandler: (_ viewController: UIViewController) -> Void = { _ in }
	public static var openFreeTextChatHandler: (_ viewController: UIViewController) -> Void = { _ in }
	public static var openConnectPaymentHandler: (_ viewController: UIViewController) -> Void = { _ in }

	@Inject var client: ApolloClient

	public init() {}
}

extension Future {
	func wait(until signal: ReadSignal<Bool>) -> Future<Value> {
		Future<Value> { completion in let bag = DisposeBag()

			self.onValue { value in
				bag += signal.atOnce().filter(predicate: { $0 })
					.onValue { _ in completion(.success(value)) }
			}
			.onError { error in completion(.failure(error)) }

			return bag
		}
	}
}

extension Home: Presentable {
	public func materialize() -> (UIViewController, Disposable) {
		let viewController = UIViewController()
		viewController.title = L10n.HomeTab.title
		viewController.installChatButton(allowsChatHint: true)

		if #available(iOS 13.0, *) {
			let scrollEdgeAppearance = UINavigationBarAppearance()
			DefaultStyling.applyCommonNavigationBarStyling(scrollEdgeAppearance)
			scrollEdgeAppearance.configureWithTransparentBackground()
			scrollEdgeAppearance.largeTitleTextAttributes = scrollEdgeAppearance.largeTitleTextAttributes
				.merging(
					[NSAttributedString.Key.foregroundColor: UIColor.clear],
					uniquingKeysWith: takeRight
				)

			viewController.navigationItem.scrollEdgeAppearance = scrollEdgeAppearance
		}

		let bag = DisposeBag()

		let form = FormView()
		bag += viewController.install(form) { scrollView in
			//            let refreshControl = UIRefreshControl()
			//			scrollView.refreshControl = refreshControl
			//			bag += self.client.refetchOnRefresh(query: GraphQL.HomeQuery(), refreshControl: refreshControl)

			bag += scrollView.performEntryAnimation(
				contentView: form,
				onLoad: self.client.fetch(query: GraphQL.HomeQuery())
					.wait(until: scrollView.safeToPerformEntryAnimationSignal).delay(by: 0.1)
			) { error in print(error) }
		}

		bag += form.append(ImportantMessagesSection())

		let titleSection = form.appendSection()
		let titleRow = RowView()
		titleRow.layoutMargins = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
		titleRow.isLayoutMarginsRelativeArrangement = true
		titleSection.append(titleRow)

		bag += NotificationCenter.default.signal(forName: UIApplication.didBecomeActiveNotification)
			.mapLatestToFuture { _ in
				self.client.fetch(query: GraphQL.HomeQuery(), cachePolicy: .fetchIgnoringCacheData)
			}
			.nil()

		bag += client.watch(query: GraphQL.HomeQuery())
			.onValueDisposePrevious { data in let innerBag = DisposeBag()

				let terminatedState = data.contracts.allSatisfy { contract -> Bool in
					if contract.status.asActiveInFutureAndTerminatedInFutureStatus != nil {
						return true
					}

					if contract.status.asTerminatedStatus != nil { return true }

					if contract.status.asTerminatedTodayStatus != nil { return true }

					return false
				}

				let futureState = data.contracts.allSatisfy { contract -> Bool in
					if contract.status.asActiveInFutureStatus != nil { return true }

					if contract.status.asPendingStatus != nil { return true }

					return false
				}

				if terminatedState {
					innerBag += titleRow.append(TerminatedSection())
				} else if futureState {
					innerBag += titleRow.append(FutureSection())
				} else {
					innerBag += titleRow.append(ActiveSection())
				}

				return innerBag
			}

		return (viewController, bag)
	}
}

extension Home: Tabable {
	public func tabBarItem() -> UITabBarItem {
		UITabBarItem(title: L10n.HomeTab.title, image: Asset.tab.image, selectedImage: Asset.tabSelected.image)
	}
}
