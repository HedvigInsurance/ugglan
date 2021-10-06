import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

struct TypingIndicator: Hashable, Equatable {
    static func == (lhs: TypingIndicator, rhs: TypingIndicator) -> Bool { lhs.id == rhs.id }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    let id = UUID()
    let listSignal: ReadSignal<[ChatListContent]>

    var previous: Message? {
        let list = listSignal.value

        guard let myIndex = list.firstIndex(of: .right(self)) else { return nil }
        let previousIndex = myIndex + 1

        if !list.indices.contains(previousIndex) { return nil }

        return list[previousIndex].left
    }

    var hasPreviousMessage: Bool { previous?.fromMyself == false }

    /// returns the totalHeight calculated height for displaying a TypingIndicator in a cell
    var totalHeight: CGFloat {
        let baseHeight: CGFloat = 40
        return hasPreviousMessage ? baseHeight : baseHeight + 20
    }
}

extension TypingIndicator: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (TypingIndicator) -> Disposable) {
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .leading
        containerView.distribution = .equalCentering

        let spacingContainer = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .leading
        spacingContainer.insetsLayoutMarginsFromSafeArea = false
        spacingContainer.isLayoutMarginsRelativeArrangement = true

        containerView.addArrangedSubview(spacingContainer)

        return (
            containerView,
            { typingIndicator in
                spacingContainer.edgeInsets = UIEdgeInsets(
                    top: typingIndicator.hasPreviousMessage ? 2 : 20,
                    left: 20,
                    bottom: 0,
                    right: 20
                )

                return spacingContainer.addArranged(typingIndicator)
            }
        )
    }
}

extension TypingIndicator: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let bubble = UIView()
        bubble.backgroundColor = Message.hedvigBubbleColor

        let typingView = UIStackView()
        typingView.spacing = 5
        typingView.alignment = .center
        typingView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 15)
        typingView.isLayoutMarginsRelativeArrangement = true

        bubble.addSubview(typingView)
        typingView.snp.makeConstraints { make in make.top.bottom.leading.trailing.equalToSuperview() }

        func getDot() -> UIView {
            let dot = UIView()
            dot.snp.makeConstraints { make in make.width.height.equalTo(5) }
            dot.layer.cornerRadius = 2.5
            dot.backgroundColor = .brand(.primaryText())
            return dot
        }

        let firstDot = getDot()
        let secondDot = getDot()
        let thirdDot = getDot()

        typingView.addArrangedSubview(firstDot)
        typingView.addArrangedSubview(secondDot)
        typingView.addArrangedSubview(thirdDot)

        bag += bubble.didLayoutSignal.onValue { _ in let halfWidthCornerRadius: CGFloat = 6

            if self.hasPreviousMessage {
                bubble.applyRadiusMaskFor(
                    topLeft: 3,
                    bottomLeft: halfWidthCornerRadius,
                    bottomRight: halfWidthCornerRadius,
                    topRight: halfWidthCornerRadius
                )
            } else {
                bubble.layer.cornerRadius = halfWidthCornerRadius
            }
        }

        bag += Signal(every: 2, delay: 0)
            .animated(
                style: AnimationStyle.easeOut(duration: 0.2),
                animations: { _ in firstDot.transform = CGAffineTransform(translationX: 0, y: -10) }
            )
            .animated(
                style: SpringAnimationStyle.ludicrousBounce(),
                animations: { _ in firstDot.transform = CGAffineTransform.identity }
            )

        bag += Signal(every: 2, delay: 0.1)
            .animated(
                style: AnimationStyle.easeOut(duration: 0.2),
                animations: { _ in secondDot.transform = CGAffineTransform(translationX: 0, y: -6) }
            )
            .animated(
                style: SpringAnimationStyle.ludicrousBounce(),
                animations: { _ in secondDot.transform = CGAffineTransform.identity }
            )

        bag += Signal(every: 2, delay: 0.2)
            .animated(
                style: AnimationStyle.easeOut(duration: 0.2),
                animations: { _ in thirdDot.transform = CGAffineTransform(translationX: 0, y: -4) }
            )
            .animated(
                style: SpringAnimationStyle.ludicrousBounce(),
                animations: { _ in thirdDot.transform = CGAffineTransform.identity }
            )

        return (bubble, bag)
    }
}
