import Foundation
import Presentation
import SwiftUI

extension Binding {
    public init<S: Store>(
        _ storeType: S.Type,
        getter: @escaping (_ state: S.State) -> Value,
        setter: @escaping (_ value: Value) -> S.Action
    ) {
        let store: S = globalPresentableStoreContainer.get()

        self.init {
            getter(store.stateSignal.value)
        } set: { newValue, _ in
            store.send(setter(newValue))
        }
    }
}
