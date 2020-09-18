import Flow
import Foundation
import hCoreUI
import UIKit

extension SignalProvider {
    func loader(after: TimeInterval, view: UIView) -> Self {
        let bag = DisposeBag()

        let overlayView = UIStackView()
        overlayView.axis = .vertical
        overlayView.isLayoutMarginsRelativeArrangement = true
        overlayView.backgroundColor = view.backgroundColor

        let loader = LoadingIndicator(showAfter: after, color: .purple)
        bag += overlayView.addArranged(loader)

        view.addSubview(overlayView)

        overlayView.snp.makeConstraints { make in
            make.width.height.centerY.centerX.equalToSuperview()
        }

        bag += overlayView.didLayoutSignal.take(first: 1).onValue { _ in
            if let navigationController = overlayView.viewController?.navigationController {
                let navigationBarHeight = navigationController.navigationBar.frame.size.height
                overlayView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: navigationBarHeight, right: 0)
            }
        }

        bag += onValue { _ in
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                overlayView.alpha = 0.0
            }) { _ in
                overlayView.removeFromSuperview()
                bag.dispose()
            }
        }

        return self
    }
}
