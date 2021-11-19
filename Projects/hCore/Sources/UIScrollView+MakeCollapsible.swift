import Flow
import Foundation
import UIKit

extension UIScrollView {
    public static func makeCollapsible(
        _ view: UIView,
        initiallyCollapsed: Bool = true
    ) -> (scrollView: UIScrollView, isExpanded: ReadWriteSignal<Bool>) {
        let scrollView = UIScrollView()
        scrollView.animationSafeIsHidden = initiallyCollapsed
        scrollView.isScrollEnabled = false
        scrollView.embedView(view, scrollAxis: .vertical)

        let isExpandedSignal = ReadWriteSignal(!initiallyCollapsed)

        let bag = DisposeBag()

        bag += isExpandedSignal.atOnce()
            .driven(by: scrollView.contentSizeSignal.atOnce())
            .throttle(0.5)
            .atValue({ isExpanded in
                if isExpanded {
                    scrollView.animationSafeIsHidden = !isExpanded
                }
            })
            .delay(by: 0.01)
            .animated(style: SpringAnimationStyle.lightBounce()) { isExpanded in
                scrollView.snp.remakeConstraints { make in
                    if !isExpanded {
                        make.height.equalTo(0)
                    } else {
                        make.height.equalTo(scrollView.contentSize.height)
                    }
                }
                scrollView.alpha = isExpanded ? 1 : 0
                scrollView.layoutIfNeeded()
                scrollView.layoutSuperviewsIfNeeded()
            }
            .onValue { isExpanded in
                scrollView.animationSafeIsHidden = !isExpanded
            }

        return (scrollView, isExpandedSignal.hold(bag))
    }
}
