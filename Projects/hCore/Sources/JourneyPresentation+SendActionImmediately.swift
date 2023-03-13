import Foundation
import Presentation

extension JourneyPresentation {
    @discardableResult
    public func sendActionImmediately<S: Store>(
        _ storeType: S.Type,
        _ action: S.Action
    ) -> Self {
        return self.onPresent {
            let store: S = self.presentable.get()
            store.send(action)
        }
    }
}
