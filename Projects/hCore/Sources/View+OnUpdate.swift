import Combine
import Foundation
import SwiftUI

extension View {
    @ViewBuilder public func onUpdate<Value: Equatable>(
        of value: Value,
        perform: @escaping (_ newValue: Value) -> Void
    ) -> some View {
        if #available(iOS 14, *) {
            self.onChange(of: value) { newValue in
                perform(newValue)
            }
        } else {
            self.onReceive(Just(value)) { _ in
                perform(value)
            }
        }
    }
}
