import Flow
import Form
import Foundation
import SnapKit
import UIKit
import hCore

public struct LoadingIndicator {
    public let showAfter: TimeInterval
    public let color: UIColor
    public let size: CGFloat

    public static let defaultLoaderColor = UIColor(dynamic: { trait -> UIColor in
        trait.userInterfaceStyle == .dark ? .white : .brand(.primaryTintColor)
    })

    public init(
        showAfter: TimeInterval,
        color: UIColor = LoadingIndicator.defaultLoaderColor,
        size: CGFloat = 100
    ) {
        self.showAfter = showAfter
        self.color = color
        self.size = size
    }
}

extension LoadingIndicator: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.alpha = 0
        loadingIndicator.color = color

        let bag = DisposeBag()

        bag += loadingIndicator.didMoveToWindowSignal.take(first: 1)
            .onValue { _ in
                loadingIndicator.snp.makeConstraints { make in make.width.equalTo(self.size)
                    make.height.equalTo(self.size)
                    make.centerX.equalToSuperview()
                }
            }

        bag += Signal(after: showAfter)
            .animated(
                style: AnimationStyle.easeOut(duration: 0.5),
                animations: {
                    loadingIndicator.alpha = 1
                    loadingIndicator.startAnimating()
                }
            )

        return (loadingIndicator, bag)
    }
}
