import Flow
import Foundation
import UIKit
import hCore

class AccessoryViewController<Accessory: Viewable>: UIViewController
where Accessory.Events == ViewableEvents, Accessory.Matter: UIView, Accessory.Result == Disposable {
  let accessoryView: Accessory.Matter

  init(
    accessoryView: Accessory
  ) {
    let (view, disposable) = accessoryView.materialize(
      events: ViewableEvents(wasAddedCallbacker: Callbacker<Void>())
    )
    self.accessoryView = view

    let bag = DisposeBag()

    bag += disposable

    super.init(nibName: nil, bundle: nil)

    bag += deallocSignal.onValue { _ in bag.dispose() }
  }

  @available(*, unavailable) required init?(
    coder _: NSCoder
  ) { fatalError("init(coder:) has not been implemented") }

  override var canBecomeFirstResponder: Bool { true }

  override var inputAccessoryView: UIView? { accessoryView }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    becomeFirstResponder()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    becomeFirstResponder()
  }
}
