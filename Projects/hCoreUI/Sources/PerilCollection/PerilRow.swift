import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

extension GraphQL.PerilFragment: Equatable {
    public static func == (lhs: GraphQL.PerilFragment, rhs: GraphQL.PerilFragment) -> Bool {
        lhs.title == rhs.title
    }
}

struct PerilRow: Hashable, Equatable {
    static func == (lhs: PerilRow, rhs: PerilRow) -> Bool {
        lhs.fragment == rhs.fragment
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fragment.title)
    }

    let fragment: GraphQL.PerilFragment
}

extension PerilRow: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (PerilRow) -> Disposable) {
        let view = UIControl()

        let backgroundColor = UIColor.brand(.secondaryBackground())
        view.backgroundColor = backgroundColor
        view.layer.cornerRadius = .defaultCornerRadius

        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 2
        view.layer.shadowOffset = CGSize(width: 0, height: 1)

        let contentContainer = UIStackView()
        contentContainer.spacing = 10
        contentContainer.axis = .horizontal
        contentContainer.isUserInteractionEnabled = false
        contentContainer.layoutMargins = UIEdgeInsets(inset: 10)
        contentContainer.isLayoutMarginsRelativeArrangement = true
        contentContainer.alignment = .center
        view.addSubview(contentContainer)

        contentContainer.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        return (
            view,
            { `self` in
                let bag = DisposeBag()

                bag += view.didLayoutSignal.onValue { _ in
                    view.layer.shadowPath =
                        UIBezierPath(
                            roundedRect: view.layer.bounds,
                            byRoundingCorners: [.allCorners],
                            cornerRadii: CGSize(
                                width: .defaultCornerRadius,
                                height: .defaultCornerRadius
                            )
                        )
                        .cgPath
                }

                let remoteVectorIcon = RemoteVectorIcon(
                    self.fragment.icon.fragments.iconFragment,
                    threaded: true
                )
                bag += contentContainer.addArranged(remoteVectorIcon) { iconView in
                    iconView.snp.makeConstraints { make in
                        make.width.height.equalTo(35)
                    }
                }

                let title = MultilineLabel(
                    value: self.fragment.title,
                    style: .brand(.headline(color: .primary))
                )
                bag += contentContainer.addArranged(title)

                bag += view.signal(for: .touchDown)
                    .animated(
                        style: .easeOut(duration: 0.25),
                        animations: { _ in
                            view.backgroundColor = backgroundColor.darkened(amount: 0.05)
                        }
                    )

                bag += view.delayedTouchCancel()
                    .animated(
                        style: .easeOut(duration: 0.25),
                        animations: { _ in
                            view.backgroundColor = backgroundColor
                        }
                    )

                bag += view.trackedTouchUpInsideSignal.onValue { _ in
                    let detail = PerilDetail(perilFragment: self.fragment, icon: remoteVectorIcon)
                    view.viewController?
                        .present(
                            detail.withCloseButton,
                            style: .detented(.preferredContentSize, .large)
                        )
                }

                return bag
            }
        )
    }
}
