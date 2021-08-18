import Flow
import Foundation
import UIKit

public final class FormScrollView: UIScrollView, GradientScroller {
    let bag = DisposeBag()
    public var appliesGradient: Bool = true

    override public init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        if appliesGradient {
            addGradient(into: bag)
        }
    }

    public init(
        frame: CGRect,
        appliesGradient: Bool
    ) {
        super.init(frame: frame)
        self.appliesGradient = appliesGradient

        if appliesGradient {
            addGradient(into: bag)
        }
    }

    @available(*, unavailable)
    required init?(
        coder _: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()

        // fix large titles being collapsed on load
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.navigationController?.navigationBar.sizeToFit()

            let contentInsetTop = self?.adjustedContentInset.top ?? 0
            if (self?.contentOffset.y ?? 0) < contentInsetTop {
                self?.setContentOffset(CGPoint(x: 0, y: -contentInsetTop), animated: true)
            }
        }
    }
}
