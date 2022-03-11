import Flow
import Presentation
import UIKit

extension UIRefreshControl {
    public func store<S: Store>(_ store: S, send: @escaping () -> S.Action, endOn: S.Action...) -> Disposable {
        let bag = DisposeBag()

        bag += self.onValue {
            store.send(send())
            bag += store.actionSignal.onValue { action in
                if endOn.contains(action) {
                    self.endRefreshing()
                }
            }
        }

        return bag
    }

    public func store<S: Store>(
        _ store: S,
        send: @escaping () -> [S.Action],
        endOn: @escaping (S.Action) -> Bool
    ) -> Disposable {
        let bag = DisposeBag()

        bag += self.onValue {
            send()
                .forEach { action in
                    store.send(action)
                }
            bag += store.actionSignal.onValue { action in
                if endOn(action) {
                    self.endRefreshing()
                }
            }
        }

        return bag
    }
}
