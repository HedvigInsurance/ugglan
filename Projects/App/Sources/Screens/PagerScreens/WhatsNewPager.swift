import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct WhatsNewPager { @Inject var client: ApolloClient }

extension WhatsNewPager: FutureConditional {
	var lastNewsSeen: String { ApplicationState.getLastNewsSeen() }

	func getPages() -> Future<[PagerItem]> {
		client.fetch(
			query: GraphQL.WhatsNewQuery(
				locale: Localization.Locale.currentLocale.asGraphQLLocale(),
				sinceVersion: lastNewsSeen
			)
		)
		.compactMap { $0.news }
		.map { news in
			news.map {
				ContentIconPagerItem(
					title: $0.title,
					paragraph: $0.paragraph,
					icon: $0.illustration.fragments.iconFragment
				)
				.pagerItem
			}
		}
	}

	func condition() -> Future<Bool> {
		let appVersion = Bundle.main.appVersion

		if appVersion.compare(lastNewsSeen, options: .numeric) == .orderedDescending {
			return getPages().map { !$0.isEmpty }
		}

		return Future(immediate: { false })
	}
}

extension WhatsNewPager: Presentable {
	func materialize() -> (UIViewController, Future<Void>) {
		var pager = Pager(
			title: "",
			buttonContinueTitle: L10n.newsProceed,
			buttonDoneTitle: L10n.newsDismiss,
			pages: []
		)
		let (viewController, future) = pager.materialize()

		getPages().onValue { pages in pager.pages = pages }

		return (viewController, future)
	}
}
