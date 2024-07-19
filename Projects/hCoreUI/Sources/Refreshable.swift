import Foundation
import Introspect
import SwiftUI

extension View {
    @ViewBuilder
    public func onPullToRefresh(action: @escaping @Sendable () async -> Void) -> some View {
        self.refreshable {
            await action()
        }
    }
}
