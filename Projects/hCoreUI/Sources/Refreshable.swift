import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    public func onPullToRefresh(action: @escaping @Sendable () async -> Void) -> some View {
        refreshable {
            await action()
        }
    }
}
