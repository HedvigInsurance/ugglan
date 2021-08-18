import Flow
import Foundation
import UIKit

extension UIViewController {
    public func install<V: Viewable, View: UIView>(_ viewable: V) -> Disposable
    where V.Matter == View, V.Result == Disposable, V.Events == ViewableEvents {
        let wasAddedCallbacker = Callbacker<Void>()
        let viewableEvents = ViewableEvents(wasAddedCallbacker: wasAddedCallbacker)
        let (matter, result) = viewable.materialize(events: viewableEvents)

        view = matter

        wasAddedCallbacker.callAll()

        return result
    }

    public func install<V: Viewable, View: UIView, SignalKind, SignalValue>(
        _ viewable: V,
        onInstall: (_ view: View) -> Void = { _ in }
    ) -> V.Result
    where V.Matter == View, V.Result == CoreSignal<SignalKind, SignalValue>, V.Events == ViewableEvents {
        let wasAddedCallbacker = Callbacker<Void>()
        let viewableEvents = ViewableEvents(wasAddedCallbacker: wasAddedCallbacker)
        let (matter, result) = viewable.materialize(events: viewableEvents)

        view = matter

        onInstall(matter)

        wasAddedCallbacker.callAll()

        return result
    }

    public func install<V: Viewable, View: UIView, FutureResult: Any>(_ viewable: V) -> Future<FutureResult>
    where V.Matter == View, V.Result == Future<FutureResult>, V.Events == ViewableEvents {
        let wasAddedCallbacker = Callbacker<Void>()
        let viewableEvents = ViewableEvents(wasAddedCallbacker: wasAddedCallbacker)
        let (matter, result) = viewable.materialize(events: viewableEvents)

        view = matter

        wasAddedCallbacker.callAll()

        return result
    }
}
