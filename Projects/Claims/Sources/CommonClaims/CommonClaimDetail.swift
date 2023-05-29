import Flow
import Form
import Foundation
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public struct CommonClaimDetail {
    let claim: CommonClaim
    public init(
        claim: CommonClaim
    ) {
        self.claim = claim
    }

    var layoutTitle: String {
        if let layoutTitle = claim.layout.emergency?.title { return layoutTitle }

        return claim.layout.titleAndBulletPoint?.title ?? ""
    }
}

extension CommonClaimDetail: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = claim.displayTitle

        let bag = DisposeBag()

        let view = UIStackView()
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        view.isLayoutMarginsRelativeArrangement = true

        let topCard = UIView()
        view.addArrangedSubview(topCard)

        let topCardContentView = UIStackView()
        topCardContentView.axis = .vertical
        topCardContentView.spacing = 15
        topCardContentView.layoutMargins = UIEdgeInsets(inset: 15)
        topCardContentView.isLayoutMarginsRelativeArrangement = true
        topCard.addSubview(topCardContentView)

        topCardContentView.snp.makeConstraints { make in
            make.bottom.trailing.leading.equalToSuperview()
            make.top.equalTo(0)
        }

        let layoutTitle = MultilineLabel(value: self.layoutTitle, style: .brand(.title2(color: .primary)))
        bag += topCardContentView.addArranged(layoutTitle)

        if let bulletPoints = claim.layout.titleAndBulletPoint?.bulletPoints {
            let claimButton = Button(
                title: claim.layout.titleAndBulletPoint?.buttonTitle ?? "",
                type: .standard(
                    backgroundColor: .brand(.secondaryButtonBackgroundColor),
                    textColor: .brand(.secondaryButtonTextColor)
                )
            )
            bag += topCardContentView.addArranged(claimButton)

            let store: ClaimsStore = self.get()
            bag += claimButton.onTapSignal.onValue {
                hAnalyticsEvent.beginClaim(screen: .commonClaimDetail).send()

                if claim.id == "30" || claim.id == "31" {
                    if let url = URL(
                        string: "https://apps.apple.com/se/app/firstvet-veterin%C3%A4r-i-mobilen/id1155459157"
                    ) {
                        UIApplication.shared.open(url)
                    }
                } else if claim.id == ClaimsState.travelInsuranceCommonClaim.id {
                    store.send(.openTravelInsurance)
                } else {
                    store.send(.submitNewClaim(from: .commonClaims(id: claim.id)))
                }
            }

            bag += view.addArranged(BulletPointTable(bulletPoints: bulletPoints))
        } else {
            let emergencyActions = EmergencyActions(presentingViewController: viewController)
            bag += view.addArranged(emergencyActions)
        }

        bag += viewController.install(view)

        viewController.trackOnAppear(hAnalyticsEvent.screenView(screen: .commonClaimDetail))

        return (viewController, bag)
    }
}


public enum ComonClaimsRedirectionType {
    case travelInsurace
}
