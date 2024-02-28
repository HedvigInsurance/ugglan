import Flow
import Foundation
import Presentation
import UIKit

public enum UIViewPresentationOptions {
    case autoRemove
}

extension UIView {
    public func addSubview<P: Presentable>(
        _ presentable: P,
        options: Set<UIViewPresentationOptions> = [],
        configure: @escaping (_ matter: P.Matter, _ result: P.Result) -> Void = { _, _ in () }
    ) -> Disposable where P.Matter: UIView, P.Result == Disposable {
        let (view, disposable) = presentable.materialize()

        self.addSubview(view)

        let bag = DisposeBag()
        bag.add(disposable)

        if options.contains(.autoRemove) {
            bag += {
                view.removeFromSuperview()
            }
        }

        configure(view, disposable)

        return bag
    }
}

extension UIStackView {
    public func addArrangedSubview<P: Presentable>(
        _ presentable: P,
        options: Set<UIViewPresentationOptions> = [],
        configure: @escaping (_ matter: P.Matter, _ result: P.Result) -> Void = { _, _ in () }
    ) -> Disposable where P.Matter: UIView, P.Result == Disposable {
        let (view, disposable) = presentable.materialize()

        self.addArrangedSubview(view)

        let bag = DisposeBag()
        bag.add(disposable)

        if options.contains(.autoRemove) {
            bag += {
                view.removeFromSuperview()
            }
        }

        configure(view, disposable)

        return bag
    }
}
