import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

struct CommonClaimCard {
    let data: GraphQL.CommonClaimsQuery.Data.CommonClaim
    let index: TableIndex
    @Inject var client: ApolloClient

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
                CommonClaimDetail(data: self.data, index: self.index).withCloseButton,
                style: .detented(.medium, .large),
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
        }))

        let label = MultilineLabel(value: data.title, style: .brand(.headline(color: .primary)))
        bag += contentView.addArranged(label)

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
