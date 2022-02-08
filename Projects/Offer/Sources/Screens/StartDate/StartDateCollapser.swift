import Foundation
import SwiftUI

struct StartDateCollapser<Content: View>: View {
    var expanded: Bool
    @ViewBuilder var expandedContent: () -> Content

    var body: some View {
        expandedContent()
            .frame(height: 300)
            .frame(maxHeight: expanded ? 300 : 0)
            .opacity(expanded ? 1 : 0)
            .clipped()
    }
}
