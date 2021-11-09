import Flow
import UIKit

public class LifeCycleProxyViewController: UIViewController {

    private let viewDidAppearCallbacker = Callbacker<Void>()

    public var viewDidAppearSignal: Signal<Void> { viewDidAppearCallbacker.providedSignal }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewDidAppearCallbacker.callAll()
    }
}
