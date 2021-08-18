import Flow
import Form
import Foundation
import UIKit
import hCore

struct ReusableDisposableViewable<View: Viewable>: Reusable
where View.Events == ViewableEvents, View.Matter: UIView, View.Result == Disposable {
  let viewable: View

  static func makeAndConfigure() -> (make: UIView, configure: (Self) -> Disposable) {
    let containerView = UIView()

    return (
      containerView,
      { anyReusable in let bag = DisposeBag()

        bag += containerView.add(anyReusable.viewable) { view in
          view.snp.remakeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
          }
        }

        return bag
      }
    )
  }
}

struct ReusableSignalViewable<View: Viewable, SignalValue>: Reusable, SignalProvider
where View.Events == ViewableEvents, View.Matter: UIView, View.Result == Signal<SignalValue> {
  let viewable: View
  var providedSignal: Signal<SignalValue> { callbacker.providedSignal }

  private let callbacker = Callbacker<SignalValue>()

  static func makeAndConfigure() -> (make: UIView, configure: (Self) -> Disposable) {
    let containerView = UIView()

    return (
      containerView,
      { anyReusable in let bag = DisposeBag()

        bag +=
          containerView.add(anyReusable.viewable) { view in
            view.snp.remakeConstraints { make in
              make.top.bottom.trailing.leading.equalToSuperview()
            }
          }
          .onValue { value in anyReusable.callbacker.callAll(with: value) }

        return bag
      }
    )
  }
}

extension ReusableSignalViewable: Hashable {
  static func == (
    _: ReusableSignalViewable<View, SignalValue>,
    _: ReusableSignalViewable<View, SignalValue>
  ) -> Bool { true }

  func hash(into hasher: inout Hasher) { hasher.combine(true) }
}
