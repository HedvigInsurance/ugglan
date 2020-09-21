import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct ActiveSection {
    @Inject var client: ApolloClient
}

extension ActiveSection: Viewable {
    func materialize(events _: ViewableEvents) -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView()
        section.dynamicStyle = .brandGrouped(separatorType: .none)

        let label = MultilineLabel(
            value: "",
            style: .brand(.largeTitle(color: .primary))
        )
        bag += section.append(label)

        client.fetch(query: GraphQL.HomeQuery()).onValue { data in
            label.valueSignal.value = L10n.HomeTab.welcomeTitle(data.member.firstName ?? "")
        }

        section.appendSpacing(.top)

        let claimButton = Button(
            title: L10n.HomeTab.claimButtonText,
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            )
        )
        bag += section.append(claimButton)
        bag += claimButton.onTapSignal.compactMap { section.viewController }.onValue(Home.openClaimsHandler)

        section.appendSpacing(.inbetween)

        let howClaimsWorkButton = Button(
            title: L10n.ClaimsExplainer.title,
            type: .iconTransparent(textColor: .brand(.primaryTintColor), icon: .left(image: hCoreUIAssets.infoSmall.image, width: 14))
        )
        bag += section.append(howClaimsWorkButton.alignedTo(alignment: .center))
        bag += howClaimsWorkButton.onTapSignal.compactMap { section.viewController }.onValue { viewController in
            var pager = Pager(
                title: L10n.ClaimsExplainer.title,
                buttonContinueTitle: L10n.ClaimsExplainer.buttonNext,
                buttonDoneTitle: L10n.ClaimsExplainer.buttonStartClaim,
                pages: []
            ) { viewController in
                Home.openClaimsHandler(viewController)
                return Future(.forever)
            }
            viewController.present(pager)

            client.fetch(query: GraphQL.HowClaimsWorkQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale())).onValue { data in
                pager.pages = data.howClaimsWork.map { ContentIconPagerItem(
                    title: nil,
                    paragraph: $0.body,
                    icon: $0.illustration.fragments.iconFragment
                ).pagerItem }
            }
        }

        section.appendSpacing(.custom(80))

        bag += section.append(CommonClaimsCollection())

        return (section, bag)
    }
}
