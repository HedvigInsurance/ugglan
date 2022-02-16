import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct ActiveSection { @Inject var client: ApolloClient }

extension ActiveSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let bag = DisposeBag()
        let section = SectionView()

        let store: HomeStore = self.get()

        section.dynamicStyle = .brandGrouped(
            insets: .init(top: 0, left: 14, bottom: 0, right: 14),
            separatorType: .none
        )

        let claims = ClaimSectionLoading()
        let hostingView = HostingView(rootView: claims)

        section.append(hostingView)

        bag += {
            hostingView.removeFromSuperview()
        }

        let claimButton = Button(
            title: L10n.HomeTab.claimButtonText,
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            )
        )
        bag += section.append(claimButton)

        bag += claimButton.onTapSignal.onValue {
            store.send(.openClaims)
        }

        bag += section.appendSpacingAndDumpOnDispose(.inbetween)

        let howClaimsWorkButton = HowClaimsWorkButton()
        bag += section.append(howClaimsWorkButton)

        bag += store.stateSignal.atOnce().map { ($0.claims?.count ?? 0) > 0 }
            .onValue { hasClaims in

                claimButton.title.value =
                    hasClaims ? L10n.Home.OpenClaim.startNewClaimButton : L10n.HomeTab.claimButtonText
                claimButton.type.value =
                    hasClaims
                    ? .standardOutline(
                        borderColor: .brand(.primaryText()),
                        textColor: .brand(.primaryText())
                    )
                    : .standard(
                        backgroundColor: .brand(.secondaryButtonBackgroundColor),
                        textColor: .brand(.secondaryButtonTextColor)
                    )
            }

        bag += section.append(ConnectPaymentCard())
        bag += section.append(RenewalCard())
        bag += section.append(CommonClaimsCollection())

        return (section, bag)
    }
}
