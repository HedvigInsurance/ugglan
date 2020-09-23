import Flow
import Form
import Foundation
import hCore
import Presentation
import UIKit

struct PresentableViewable<View: Viewable, SignalValue>: Presentable where View.Events == ViewableEvents, View.Matter: UIView, View.Result == Signal<SignalValue> {
    let viewable: View
    let customizeViewController: (_ vc: UIViewController) -> Void

    public init(
        viewable: View,
        customizeViewController: @escaping (_ vc: UIViewController) -> Void = { _ in }
    ) {
        self.viewable = viewable
        self.customizeViewController = customizeViewController
    }

    func materialize() -> (UIViewController, Signal<SignalValue>) {
        let viewController = UIViewController()
        customizeViewController(viewController)

        let bag = DisposeBag()

        return (viewController, viewController.install(viewable) { view in
            bag += view.traitCollectionSignal.onValue { _ in
                self.customizeViewController(viewController)
            }
        }.hold(bag))
    }
}
