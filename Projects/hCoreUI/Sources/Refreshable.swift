import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    public func onPullToRefresh(action: @escaping @Sendable () async -> Void) -> some View {
        refreshable {
            // `.refreshable` cancels its task as soon as the refresh control retracts,
            // which would cancel `action` mid-flight. Detach the work into an unstructured
            // Task so cancellation doesn't propagate, while still awaiting completion to
            // keep the refresh indicator visible until the work finishes.
            await Task {
                await action()
            }
            .value
        }
    }
}
