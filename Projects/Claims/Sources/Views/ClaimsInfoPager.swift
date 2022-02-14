import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct ClaimsInfoPager {
    @Inject var client: ApolloClient
    @PresentableStore var store: ClaimsStore
    
    public init() {
        
    }
}

extension ClaimsInfoPager: Presentable {
    public func materialize() -> (UIViewController, Future<Void>) {
        var pager = Pager(
            title: L10n.ClaimsExplainer.title,
            buttonContinueTitle: L10n.ClaimsExplainer.buttonNext,
            buttonDoneTitle: L10n.ClaimsExplainer.buttonStartClaim,
            pages: []
        ) { viewController in
            store.send(.submitClaims)
            return Future(.forever)
        }
        
        let (viewController, future) = pager.materialize()
        
        client.fetch(
            query: GraphQL.HowClaimsWorkQuery(
                locale: Localization.Locale.currentLocale.asGraphQLLocale()
            )
        )
            .onValue { data in
                pager.pages = data.howClaimsWork.map {
                    ContentIconPagerItem(
                        title: nil,
                        paragraph: $0.body,
                        icon: $0.illustration.fragments.iconFragment
                    )
                        .pagerItem
                }
            }
        
        return (
            viewController,
            future
        )
    }
}


