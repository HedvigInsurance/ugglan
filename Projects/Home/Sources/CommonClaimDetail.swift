import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct CommonClaimDetail {
    let data: GraphQL.CommonClaimsQuery.Data.CommonClaim
    let index: TableIndex

    var layoutTitle: String {
        if let layoutTitle = data.layout.asEmergency?.title {
            return layoutTitle
        }

        return data.layout.asTitleAndBulletPoints?.title ?? ""
    }
}

extension CommonClaimDetail: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = data.title

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
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        let icon = RemoteVectorIcon(data.icon.fragments.iconFragment, threaded: true)
        bag += topCardContentView.addArranged(icon.alignedTo(.leading, configure: { iconView in
            iconView.snp.makeConstraints { make in
                make.height.width.equalTo(30)
            }
        }))

        let layoutTitle = MultilineLabel(value: self.layoutTitle, style: .brand(.title2(color: .primary)))
        bag += topCardContentView.addArranged(layoutTitle)

        if let bulletPoints = data.layout.asTitleAndBulletPoints?.bulletPoints {
            let claimButton = Button(
                title: data.layout.asTitleAndBulletPoints?.buttonTitle ?? "",
                type: .standard(
                    backgroundColor: .brand(.primaryButtonBackgroundColor),
                    textColor: .brand(.primaryButtonTextColor)
                )
            )
            bag += topCardContentView.addArranged(claimButton)

            bag += claimButton.onTapSignal.onValue { _ in
                Home.openClaimsHandler(viewController)
            }

            bag += view.addArranged(BulletPointTable(
                bulletPoints: bulletPoints
            ))
        } else {
            let emergencyActions = EmergencyActions(presentingViewController: viewController)
            bag += view.addArranged(emergencyActions)
        }

        bag += viewController.install(view)

        return (viewController, bag)
    }
}
