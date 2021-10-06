import Flow
import Form
import Foundation
import UIKit

extension RowView {
    public func append<V: Viewable, View: UIView>(
        _ viewable: V,
        onCreate: @escaping (_ view: View) -> Void = { _ in }
    ) -> Disposable where V.Matter == View, V.Result == Disposable, V.Events == ViewableEvents {
        let wasAddedCallbacker = Callbacker<Void>()

        let (matter, result) = viewable.materialize(
            events: ViewableEvents(wasAddedCallbacker: wasAddedCallbacker)
        )

        let bag = DisposeBag()

        append(matter)
        onCreate(matter)

        return Disposer {
            result.dispose()
            bag.dispose()
            matter.removeFromSuperview()
        }
    }

    public func append<V: Viewable, View: UIView, Value>(
        _ viewable: V,
        onCreate: @escaping (_ view: View) -> Void = { _ in }
    ) -> Signal<Value> where V.Matter == View, V.Result == Signal<Value>, V.Events == ViewableEvents {
        let wasAddedCallbacker = Callbacker<Void>()

        let (matter, result) = viewable.materialize(
            events: ViewableEvents(wasAddedCallbacker: wasAddedCallbacker)
        )

        append(matter)
        onCreate(matter)

        return result
    }

    public func append<V: Viewable, View: UIView, Value>(
        _ viewable: V,
        onCreate: @escaping (_ view: View) -> Void = { _ in }
    ) -> ReadWriteSignal<Value>
    where V.Matter == View, V.Result == ReadWriteSignal<Value>, V.Events == ViewableEvents {
        let wasAddedCallbacker = Callbacker<Void>()

        let (matter, result) = viewable.materialize(
            events: ViewableEvents(wasAddedCallbacker: wasAddedCallbacker)
        )

        append(matter)
        onCreate(matter)

        return result
    }
}
