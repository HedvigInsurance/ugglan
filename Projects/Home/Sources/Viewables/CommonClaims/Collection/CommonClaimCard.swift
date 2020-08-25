//
//  CommonClaimCard.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-04-12.
//

import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Hero
import hGraphQL
import Presentation
import UIKit

struct CommonClaimCard {
    let data: GraphQL.CommonClaimsQuery.Data.CommonClaim
    let index: TableIndex
    @Inject var client: ApolloClient

    static var cardModifier: HeroModifier {
        .spring(stiffness: 350, damping: 50)
    }

    init(
        data: GraphQL.CommonClaimsQuery.Data.CommonClaim,
        index: TableIndex
    ) {
        self.index = index
        self.data = data
    }
}

extension CommonClaimCard: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let containerView = UIControl()
        containerView.layer.cornerRadius = 8
        containerView.hero.id = "TopCard_\(index.row)"
        containerView.hero.modifiers = [Self.cardModifier]
        containerView.backgroundColor = .brand(.secondaryBackground())

        bag += containerView.applyShadow { _ in
            UIView.ShadowProperties(
                opacity: 0.1,
                offset: CGSize(width: 0, height: 1),
                radius: 2,
                color: .brand(.primaryShadowColor),
                path: nil
            )
        }

        bag += containerView.signal(for: .touchUpInside).feedback(type: .impactLight)

        bag += containerView.signal(for: .touchDown).animated(style: SpringAnimationStyle.lightBounce()) { _ in
            containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }

        bag += containerView.delayedTouchCancel().animated(style: SpringAnimationStyle.lightBounce()) { _ in
            containerView.transform = CGAffineTransform.identity
        }

        bag += containerView.trackedTouchUpInsideSignal.onValue {
            containerView.viewController?.present(
                CommonClaimDetail(data: data, index: index).withCloseButton,
                style: .hero,
                options: [.defaults]
            )
        }

        let contentView = UIStackView()
        contentView.layoutMargins = UIEdgeInsets(inset: 10)
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.isUserInteractionEnabled = false
        contentView.axis = .vertical
        contentView.distribution = .equalSpacing
        containerView.addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        let icon = RemoteVectorIcon(data.icon.fragments.iconFragment, threaded: true)
        bag += contentView.addArranged(icon.alignedTo(.leading, configure: { iconView in
            iconView.snp.makeConstraints { make in
                make.height.width.equalTo(30)
            }
            iconView.hero.id = "IconView_\(self.index.row)"
            iconView.hero.modifiers = [Self.cardModifier]
        }))

        let label = MultilineLabel(value: data.title, style: .brand(.headline(color: .primary)))
        bag += contentView.addArranged(label) { labelView in
            labelView.hero.id = "LabelView_\(self.index.row)"
            labelView.hero.modifiers = [
                .when({ context -> Bool in
                    context.isAppearing && context.isAncestorViewMatched
                }, [
                    .fade, .delay(0.15),
                ]),
                .when({ context -> Bool in
                    !context.isAppearing && context.isAncestorViewMatched
                }, [
                    .fade, .translate(x: 0, y: -20, z: 0), .duration(0.10), .useGlobalCoordinateSpace,
                ]),
            ]
        }

        return (containerView, bag)
    }
}

extension CommonClaimCard: Reusable {
    public static func makeAndConfigure() -> (
        make: UIView,
        configure: (CommonClaimCard) -> Disposable
    ) {
        let containerView = UIStackView()
        containerView.isLayoutMarginsRelativeArrangement = true

        return (containerView, { commonClaimCard in
            let bag = DisposeBag()

            containerView.layoutMargins = UIEdgeInsets(
                top: 10,
                left: 0,
                bottom: 10,
                right: 0
            )

            bag += containerView.addArranged(commonClaimCard)

            return bag
        })
    }
}
