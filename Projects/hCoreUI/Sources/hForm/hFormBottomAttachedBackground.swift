import Foundation
import SwiftUI

public struct hFormBottomAttachedBackground<Content: View>: View {
    var content: () -> Content

    public init(
        content: @escaping () -> Content
    ) {
        self.content = content
    }

    public var body: some View {
        VStack {
            hSeparatorColorOld.separator.frame(height: .hairlineWidth)
                .edgesIgnoringSafeArea(.horizontal)
            content().padding(16)
        }
        .background(hBackgroundColor.primary.edgesIgnoringSafeArea([.bottom, .horizontal]))
    }
}
