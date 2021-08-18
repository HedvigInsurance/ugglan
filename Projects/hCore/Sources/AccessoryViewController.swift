import Flow
import Foundation
import Presentation
import UIKit

public class AccessoryBaseView: UIView {
    public override var intrinsicContentSize: CGSize { CGSize(width: 0, height: 0) }

    public init() {
        super.init(frame: .zero)
        autoresizingMask = .flexibleHeight
    }

    required init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class AccessoryViewController<Accessory: Presentable>: UIViewController
where Accessory.Matter: UIView, Accessory.Result == Disposable {
    let accessoryView: Accessory.Matter

    public init(
        accessoryView: Accessory
    ) {
        let (view, disposable) = accessoryView.materialize()
        self.accessoryView = view

        let bag = DisposeBag()

        bag += disposable

        super.init(nibName: nil, bundle: nil)

        bag += deallocSignal.onValue { _ in bag.dispose() }
    }

    @available(*, unavailable) required init?(
        coder _: NSCoder
    ) { fatalError("init(coder:) has not been implemented") }

    public override var canBecomeFirstResponder: Bool { true }

    public override var inputAccessoryView: UIView? { accessoryView }

    public override var disablesAutomaticKeyboardDismissal: Bool { true }
}
