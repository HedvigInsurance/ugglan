import Apollo
import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct WelcomePager {
    @Inject var client: ApolloClient
}

extension WelcomePager: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        var pager = Pager(
            title: "",
            buttonContinueTitle: L10n.newMemberProceed,
            buttonDoneTitle: L10n.newMemberDismiss,
            pages: []
        )
        let (viewController, future) = pager.materialize()

        client
            .fetch(query: GraphQL.WelcomeQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale()))
            .compactMap { $0.welcome }
            .onValue { welcome in
                pager.pages = welcome.map {
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
