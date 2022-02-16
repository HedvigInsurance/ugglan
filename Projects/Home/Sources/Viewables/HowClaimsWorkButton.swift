import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct HowClaimsWorkButton { @Inject var client: ApolloClient }

extension HowClaimsWorkButton: Presentable {
    func materialize() -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        let store: HomeStore = self.get()
        
        let howClaimsWorkButton = Button(
            title: L10n.ClaimsExplainer.title,
            type: .iconTransparent(
                textColor: .brand(.primaryTintColor),
                icon: .left(image: hCoreUIAssets.infoSmall.image, width: .smallIconWidth)
            )
        )
        bag += stackView.addArranged(howClaimsWorkButton.alignedTo(alignment: .center))

        bag += howClaimsWorkButton.onTapSignal.compactMap { stackView.viewController }
            .onValue { viewController in
                var pager = Pager(
                    title: L10n.ClaimsExplainer.title,
                    buttonContinueTitle: L10n.ClaimsExplainer.buttonNext,
                    buttonDoneTitle: L10n.ClaimsExplainer.buttonStartClaim,
                    pages: []
                ) { viewController in
                    store.send(.openClaims)
                    //viewController.dismiss(animated: true)
                    return Future(.forever)
                }
                viewController.present(pager)

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
            }
        
        return (stackView, bag)
    }
}
