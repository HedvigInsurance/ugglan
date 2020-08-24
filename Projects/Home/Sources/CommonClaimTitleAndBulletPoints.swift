//
//  CommonClaimTitleAndBulletPoints.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-15.
//

import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Hero
import hGraphQL
import Presentation
import UIKit

struct CommonClaimTitleAndBulletPoints {
    let data: GraphQL.CommonClaimsQuery.Data.CommonClaim
    let index: TableIndex
}

extension CommonClaimTitleAndBulletPoints: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        viewController.title = data.title
        let bag = DisposeBag()

        let view = UIStackView()
        view.axis = .vertical

        let topCard = UIView()
        topCard.hero.id = "TopCard_\(index.row)"
        topCard.hero.modifiers = [CommonClaimCard.cardModifier]
        topCard.backgroundColor = .brand(.primaryBackground())
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

            iconView.hero.id = "IconView_\(index.row)"
            iconView.hero.modifiers = [CommonClaimCard.cardModifier]
        }))

        let sharedModifiers: [HeroModifier] = [
            .whenAppearing(.translate(x: 0, y: 25, z: 0), .fade, CommonClaimCard.cardModifier, .delay(0.15)),
            .whenDisappearing(.translate(x: 0, y: 25, z: 0), .fade, CommonClaimCard.cardModifier),
        ]

        let layoutTitle = MultilineLabel(value: data.layout.asTitleAndBulletPoints?.title ?? "", style: .brand(.title1(color: .primary)))
        bag += topCardContentView.addArranged(layoutTitle) { layoutTitle in
            layoutTitle.hero.modifiers = sharedModifiers
        }

        let claimButton = Button(
            title: data.layout.asTitleAndBulletPoints?.buttonTitle ?? "",
            type: .standard(
                backgroundColor: .brand(.primaryButtonBackgroundColor),
                textColor: .brand(.primaryButtonTextColor)
            )
        )
        bag += topCardContentView.addArranged(claimButton) { buttonView in
            buttonView.hero.modifiers = sharedModifiers
        }

        bag += claimButton.onTapSignal.onValue { _ in
            Home.openClaimsHandler(viewController)
        }

        if let bulletPoints = data.layout.asTitleAndBulletPoints?.bulletPoints {
            bag += view.addArranged(BulletPointTable(
                bulletPoints: bulletPoints
            )) { tableView in
                tableView.hero.modifiers = sharedModifiers
            }
        }

        bag += viewController.install(view)

        return (viewController, Future { _ in
            DelayedDisposer(bag, delay: 1)
        })
    }
}
