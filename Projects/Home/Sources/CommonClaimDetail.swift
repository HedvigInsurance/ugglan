//
//  CommonClaimDetail.swift
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
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        viewController.title = data.title
        viewController.hero.isEnabled = true

        let bag = DisposeBag()

        let view = UIStackView()
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        view.isLayoutMarginsRelativeArrangement = true

        let topCard = UIView()
        topCard.hero.id = "TopCard_\(index.row)"
        topCard.hero.modifiers = [CommonClaimCard.cardModifier]
        topCard.backgroundColor = .brand(.primaryBackground())
        view.addArrangedSubview(topCard)

        let panGesture = UIPanGestureRecognizer()
        bag += topCard.install(panGesture)

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
            .whenDisappearing(.translate(x: 0, y: 25, z: 0), .fade, .duration(0.25)),
        ]

        let shouldComplete = Callbacker<Void>()

        let panGestureSignal = panGesture.providedSignal

        bag += panGestureSignal.onValue { _ in
            let translation = panGesture.translation(in: view)
            switch panGesture.state {
            case .began:
                viewController.dismiss(animated: true, completion: nil)
            case .changed:
                Hero.shared.update(translation.y / view.bounds.height)
            default:
                let velocity = panGesture.velocity(in: view)
                if ((translation.y + velocity.y) / view.bounds.height) > 0.5 {
                    Hero.shared.finish()
                    shouldComplete.callAll()
                } else {
                    Hero.shared.cancel()
                    Hero.shared.containerColor = .clear
                }
            }
        }

        func updateOpacityModifier(forState state: UIPanGestureRecognizer.State, in view: UIView) {
            if state != .ended {
                let translation = panGesture.translation(in: topCard)
                Hero.shared.apply(modifiers: [.opacity(1 - (translation.y / 50))], to: view)
            }
        }

        let layoutTitle = MultilineLabel(value: self.layoutTitle, style: .brand(.title1(color: .primary)))
        bag += topCardContentView.addArranged(layoutTitle) { layoutTitleView in
            layoutTitleView.hero.modifiers = [sharedModifiers, [.useGlobalCoordinateSpace]].flatMap { $0 }

            bag += panGestureSignal.onValue { state in
                updateOpacityModifier(forState: state, in: layoutTitleView)
            }
        }

        if let bulletPoints = data.layout.asTitleAndBulletPoints?.bulletPoints {
            let claimButton = Button(
                title: data.layout.asTitleAndBulletPoints?.buttonTitle ?? "",
                type: .standard(
                    backgroundColor: .brand(.primaryButtonBackgroundColor),
                    textColor: .brand(.primaryButtonTextColor)
                )
            )
            bag += topCardContentView.addArranged(claimButton) { buttonView in
                buttonView.hero.modifiers = [sharedModifiers, [.useGlobalCoordinateSpace]].flatMap { $0 }

                bag += panGestureSignal.onValue { state in
                    updateOpacityModifier(forState: state, in: buttonView)
                }
            }

            bag += claimButton.onTapSignal.onValue { _ in
                Home.openClaimsHandler(viewController)
            }

            bag += view.addArranged(BulletPointTable(
                bulletPoints: bulletPoints
            )) { tableView in
                tableView.hero.modifiers = sharedModifiers

                bag += panGestureSignal.onValue { state in
                    updateOpacityModifier(forState: state, in: tableView)
                }
            }
        } else {
            let emergencyActions = EmergencyActions(presentingViewController: viewController)
            bag += view.addArranged(emergencyActions) { emergencyActionsView in
                emergencyActionsView.hero.modifiers = sharedModifiers

                bag += panGestureSignal.onValue { state in
                    updateOpacityModifier(forState: state, in: emergencyActionsView)
                }
            }
        }

        bag += viewController.install(view)

        return (viewController, Future { completion in
            bag += shouldComplete.onValue {
                completion(.success)
            }

            return DelayedDisposer(bag, delay: 1)
        })
    }
}
