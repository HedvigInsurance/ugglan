import Foundation
import SwiftUI

struct StartDateCollapser<Content: View>: View {
    @State var hasAppeared = false
    var expanded: Bool
    @ViewBuilder var expandedContent: () -> Content
    
    var shouldExpand: Bool {
        expanded && hasAppeared
    }

    var body: some View {
        expandedContent()
            .frame(maxHeight: shouldExpand ? .infinity : 0)
            .opacity(shouldExpand ? 1 : 0)
            .clipped()
            .onAppear {
                withAnimation(.interpolatingSpring(stiffness: 250, damping: 100).delay(0.15)) {
                    hasAppeared = true
                }
            }
    }
}
