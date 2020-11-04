import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct ContractDetailSegmentedControl {
    let form: FormView
    let scrollView: UIScrollView
}

extension ContractDetailSegmentedControl: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Signal<IndexPath>) {
        let bag = DisposeBag()

        let segmentedControlBackgroundView = UIView()
        segmentedControlBackgroundView.hero.modifiers = [
            .translate(x: 0, y: 40, z: 0),
            .opacity(0),
            .spring(stiffness: 250, damping: 30),
        ]
        segmentedControlBackgroundView.backgroundColor = .brand(.primaryBackground())

        let segmentedControlBorderView = UIView()
        segmentedControlBorderView.alpha = 0
        segmentedControlBorderView.backgroundColor = .brand(.primaryBorderColor)

        segmentedControlBackgroundView.addSubview(segmentedControlBorderView)

        segmentedControlBorderView.snp.makeConstraints { make in
            make.height.equalTo(CGFloat.hairlineWidth)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        let segmentedControlContainer = UIStackView()
        segmentedControlContainer.edgeInsets = UIEdgeInsets(
            horizontalInset: 15,
            verticalInset: SpacingType.inbetween.height
        )

        segmentedControlBackgroundView.addSubview(segmentedControlContainer)

        segmentedControlContainer.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        let segmentedControl = UISegmentedControl(titles: [
            L10n.InsuranceDetailsView.tab1Title,
            L10n.InsuranceDetailsView.tab2Title,
            L10n.InsuranceDetailsView.tab3Title,
        ])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControlContainer.addArrangedSubview(segmentedControl)

        bag += scrollView.signal(for: \.contentOffset).onValue { contentOffset in
            form.bringSubviewToFront(segmentedControlBackgroundView)

            let originY = segmentedControlBackgroundView.frameWithoutTransform.origin.y
            let contentOffsetY = contentOffset.y + scrollView.adjustedContentInset.top

            if contentOffsetY > originY {
                segmentedControlBorderView.alpha = 1
                segmentedControlBackgroundView.transform = CGAffineTransform(
                    translationX: 0,
                    y: contentOffsetY - originY
                )
            } else {
                segmentedControlBorderView.alpha = 0
                segmentedControlBackgroundView.transform = .identity
            }
        }

        return (segmentedControlBackgroundView, Signal { callback in
            bag += segmentedControl.onValue { index in
                // scrollView.scrollToTop(animated: true)
                callback(IndexPath(item: index, section: 0))
            }

            return bag
        })
    }
}
