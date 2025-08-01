import Combine
import Foundation
import SwiftUI

extension View {
    @ViewBuilder public func onUpdate<Value: Equatable>(
        of value: Value,
        perform: @escaping (_ newValue: Value) -> Void
    ) -> some View {
        onChange(of: value) { newValue in
            perform(newValue)
        }
    }
}
