import Flow
import Foundation
import UIKit

extension UIBarButtonItem {
    public convenience init<V: Viewable, View: UIView>(
        viewable: V,
        onCreate: @escaping (_ view: View) -> Void = { _ in }
    ) where V.Matter == View, V.Events == ViewableEvents, V.Result == Disposable {
        let wasAddedCallbacker = Callbacker<Void>()
        let events = ViewableEvents(wasAddedCallbacker: wasAddedCallbacker)

        let bag = DisposeBag()

        let (matter, result) = viewable.materialize(events: events)

        onCreate(matter)

        bag += result

        self.init(customView: matter)

        bag += deallocSignal.onValue { bag.dispose() }
    }
}
