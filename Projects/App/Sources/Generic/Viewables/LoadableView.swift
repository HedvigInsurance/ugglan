import Flow
import Foundation
import hCore
import UIKit

struct LoadableView<V: Viewable> where V.Matter: UIView, V.Result == Disposable {
    let view: V
    let isLoadingSignal: ReadWriteSignal<Bool>

    init(view: V, initialLoadingState: Bool = false) {
        self.view = view
        isLoadingSignal = ReadWriteSignal(initialLoadingState)
    }
}

extension LoadableView: Viewable {
    func materialize(events: V.Events) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let (matter, result) = view.materialize(events: events)

        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.addArrangedSubview(matter)

        let loadingIndicator = UIActivityIndicatorView(style: .white)
        loadingIndicator.alpha = 0
        loadingIndicator.color = .purple

        containerView.addSubview(loadingIndicator)

        loadingIndicator.snp.makeConstraints { make in
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.top.equalTo(10)
        }

        func handleStateChange(isLoading: Bool) {
            if isLoading {
                matter.alpha = 0
                matter.transform = CGAffineTransform(translationX: 0, y: 50)
                loadingIndicator.isHidden = false
                loadingIndicator.startAnimating()
                loadingIndicator.alpha = 1
            } else {
                matter.alpha = 1
                matter.transform = CGAffineTransform.identity
                loadingIndicator.isHidden = true
                loadingIndicator.stopAnimating()
                loadingIndicator.alpha = 0
            }

            containerView.layoutIfNeeded()
        }

        bag += isLoadingSignal.atOnce().take(first: 1).onValue { isLoading in
            handleStateChange(isLoading: isLoading)
        }

        bag += isLoadingSignal.delay(by: 0.25).animated(style: SpringAnimationStyle.lightBounce()) { isLoading in
            handleStateChange(isLoading: isLoading)
        }

        return (containerView, Disposer {
            result.dispose()
            bag.dispose()
        })
    }
}
