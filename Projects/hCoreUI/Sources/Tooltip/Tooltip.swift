import Flow
import Foundation
import hCore
import Presentation
import UIKit

public struct Tooltip {
    var id: String
    var value: String
    var sourceRect: CGRect

    func when(_ when: WhenTooltip.When) -> WhenTooltip {
        WhenTooltip(when: when, tooltip: self)
    }

    init(id: String, value: String, sourceRect: CGRect) {
        self.id = id
        self.value = value
        self.sourceRect = sourceRect
    }
}

extension UIView {
    public func present(_ tooltip: Tooltip) -> Disposable {
        let bag = DisposeBag()
        let tooltipView = tooltip.materialize(into: bag)
        tooltipView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).concatenating(CGAffineTransform(translationX: 0, y: -20))

        addSubview(tooltipView)

        bag += Signal(after: 0).feedback(type: .impactLight)

        let disposer = Disposer {
            bag += Signal(after: 0).animated(style: .lightBounce()) {
                tooltipView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                tooltipView.alpha = 0
            }.onValue { _ in
                bag.dispose()
                tooltipView.removeFromSuperview()
            }
        }

        tooltipView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.bottom).offset(14)
            make.right.equalTo(self.snp.right)
        }

        bag += tooltipView.windowSignal.atOnce().compactMap { $0 }.take(first: 1).animated(style: .lightBounce()) { window in
            tooltipView.transform = .identity

            class Delegate: NSObject, UIGestureRecognizerDelegate {
                let onReceiveTouch: (_ touch: UITouch) -> Void

                init(onReceiveTouch: @escaping (_ touch: UITouch) -> Void) {
                    self.onReceiveTouch = onReceiveTouch
                    super.init()
                }

                func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
                    onReceiveTouch(touch)
                    return false
                }
            }

            let delegate = Delegate { touch in
                let touchPoint = touch.location(in: tooltipView)
                guard tooltipView.hitTest(touchPoint, with: nil) != nil else {
                    return
                }
                disposer.dispose()
            }
            bag.hold(delegate)

            let tapGesture = UITapGestureRecognizer()
            tapGesture.delegate = delegate
            bag += window.rootView.install(tapGesture)
        }

        bag += Signal(after: 5).onValue { _ in
            disposer.dispose()
        }

        return disposer
    }
}

extension Tooltip: Presentable {
    public func materialize() -> (UIView, Disposable) {
        let bag = DisposeBag()

        let backgroundView = UIView()
        backgroundView.backgroundColor = .brand(.primaryButtonBackgroundColor)
        backgroundView.layer.cornerRadius = .defaultCornerRadius
        backgroundView.layer.masksToBounds = false

        bag += backgroundView.applyShadow { _ -> UIView.ShadowProperties in
            UIView.ShadowProperties(
                opacity: 1,
                offset: CGSize(width: 0, height: 4.58),
                radius: 4.58,
                color: .brand(.primaryShadowColor),
                path: nil
            )
        }

        let triangleView = TriangleView(frame: .zero, color: .brand(.primaryButtonBackgroundColor))
        backgroundView.addSubview(triangleView)

        triangleView.snp.makeConstraints { make in
            make.height.equalTo(8)
            make.width.equalTo(16)
            make.right.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(-6)
        }

        let contentContainer = UIStackView()
        contentContainer.isLayoutMarginsRelativeArrangement = true
        contentContainer.insetsLayoutMarginsFromSafeArea = false
        contentContainer.layoutMargins = UIEdgeInsets(horizontalInset: 16, verticalInset: 10)
        backgroundView.addSubview(contentContainer)

        contentContainer.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        let label = UILabel(value: value, style: .brand(.body(color: .primary(state: .positive))))
        contentContainer.addArrangedSubview(label)

        return (backgroundView, bag)
    }
}
