import Apollo
import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct WhatsNewPager {
    @Inject var client: ApolloClient
}

extension WhatsNewPager: Conditional {
    var lastNewsSeen: String {
        ApplicationState.getLastNewsSeen()
    }

    func condition() -> Bool {
        let appVersion = Bundle.main.appVersion
        return appVersion.compare(lastNewsSeen, options: .numeric) == .orderedDescending
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

        client
            .fetch(query: GraphQL.WhatsNewQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale(), sinceVersion: lastNewsSeen))
            .compactMap { $0.news }
            .onValue { news in
                pager.pages = news.map {
                    ContentIconPagerItem(
                        title: $0.title,
                        paragraph: $0.paragraph,
                        icon: $0.illustration.fragments.iconFragment
                    ).pagerItem
                }
            }

        return (viewController, future)
    }
}
