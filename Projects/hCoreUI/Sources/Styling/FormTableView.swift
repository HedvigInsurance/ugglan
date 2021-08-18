import Flow
import Foundation
import UIKit

final class FormTableView: UITableView, GradientScroller {
    let bag = DisposeBag()

    override init(
        frame: CGRect,
        style: UITableView.Style
    ) {
        super.init(frame: frame, style: style)
        addGradient(into: bag)
    }

    @available(*, unavailable) required init?(
        coder _: NSCoder
    ) { fatalError("init(coder:) has not been implemented") }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        // fix large titles being collapsed on load
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.navigationController?.navigationBar.sizeToFit()

            if (self?.contentOffset.y ?? 0) < 0 {
                let contentInsetTop = self?.adjustedContentInset.top ?? 0
                self?.setContentOffset(CGPoint(x: 0, y: -contentInsetTop), animated: true)
            }
        }
    }
}
