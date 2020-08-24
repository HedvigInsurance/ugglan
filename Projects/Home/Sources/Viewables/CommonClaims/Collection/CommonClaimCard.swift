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

    enum State {
        case normal, expanded
    }

    let backgroundStateSignal = ReadWriteSignal<State>(.normal)
    let cornerRadiusSignal = ReadWriteSignal<CGFloat>(8)
    let iconTopPaddingStateSignal = ReadWriteSignal<State>(.normal)
    let titleLabelStateSignal = ReadWriteSignal<State>(.normal)
    let controlIsEnabledSignal = ReadWriteSignal<Bool>(true)
    let shadowOpacitySignal = ReadWriteSignal<Float>(0.05)
    let showTitleCloseButton = ReadWriteSignal<Bool>(false)
    let showClaimButtonSignal = ReadWriteSignal<Bool>(false)
    let scrollPositionSignal = ReadWriteSignal<CGPoint>(CGPoint(x: 0, y: 0))

    let claimButtonTapSignal: Signal<Void>
    let closeSignal: Signal<Void>
    private let closeCallbacker: Callbacker<Void>
    private let claimButtonTapCallbacker: Callbacker<Void>

    func iconTopPadding(state: State) -> CGFloat {
        state == .normal ? 15 : 65 + safeAreaTop
    }

    func height(state: State) -> CGFloat {
        let attributedString = NSAttributedString(styledText: StyledText(
            text: layoutTitle,
            style: .brand(.title3(color: .primary))
        ))

        let size = attributedString.boundingRect(
            with: CGSize(width: UIScreen.main.bounds.width - 40, height: 1000),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        let buttonPadding: CGFloat = includeButton ? 70 : 0

        return state == .normal ? 0 : (size.height + iconTopPadding(state: state) + 60 + buttonPadding)
    }

    var isFirstInRow: Bool {
        let dividedIndex = Double(index.row) / 2
        return rint(dividedIndex) == dividedIndex
    }

    var layoutTitle: String {
        if let title = data.layout.asTitleAndBulletPoints?.title {
            return title
        }

        if let title = data.layout.asEmergency?.title {
            return title
        }

        return ""
    }

    var safeAreaTop: CGFloat {
        let keyWindow = UIApplication.shared.keyWindow
        return keyWindow?.safeAreaInsets.top ?? 0
    }

    var includeButton: Bool {
        data.layout.asTitleAndBulletPoints != nil
    }

    static var cardModifier: HeroModifier {
        .spring(stiffness: 350, damping: 50)
    }

    init(
        data: GraphQL.CommonClaimsQuery.Data.CommonClaim,
        index: TableIndex
    ) {
        self.index = index
        self.data = data
        closeCallbacker = Callbacker()
        closeSignal = closeCallbacker.providedSignal
        claimButtonTapCallbacker = Callbacker()
        claimButtonTapSignal = claimButtonTapCallbacker.providedSignal
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

        bag += containerView.signal(for: .touchUpInside).feedback(type: .impactLight)

        bag += containerView.signal(for: .touchDown).animated(style: SpringAnimationStyle.lightBounce()) { _ in
            containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }

        bag += containerView.delayedTouchCancel().animated(style: SpringAnimationStyle.lightBounce()) { _ in
            containerView.transform = CGAffineTransform.identity
        }

        bag += containerView.trackedTouchUpInsideSignal.onValue {
            if data.layout.asEmergency != nil {
                containerView.viewController?.present(
                    CommonClaimEmergency(data: data, index: index).withCloseButton,
                    style: .hero,
                    options: [.defaults]
                )
            } else {
                containerView.viewController?.present(
                    CommonClaimTitleAndBulletPoints(data: data, index: index).withCloseButton,
                    style: .hero,
                    options: [.defaults]
                )
            }
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
            iconView.hero.id = "IconView_\(index.row)"
            iconView.hero.modifiers = [Self.cardModifier]
        }))

        let label = MultilineLabel(value: data.title, style: .brand(.headline(color: .primary)))
        bag += contentView.addArranged(label) { labelView in
            labelView.hero.modifiers = []
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
