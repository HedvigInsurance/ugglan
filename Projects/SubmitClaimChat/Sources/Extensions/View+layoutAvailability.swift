import SwiftUI

extension View {
    @ViewBuilder
    func geometryGroupIfAvailable() -> some View {
        if #available(iOS 17.0, *) {
            geometryGroup()
        } else {
            self
        }
    }
}
