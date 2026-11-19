import SwiftUI
import hCore
import hCoreUI

/// Shared chrome of the Messages screens, matching the chat Inbox: the standard white navigation bar with a centred
/// title and the scrolling `hForm` content.
struct MessagesScreenLayout<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        hForm {
            content()
                .padding(.top, .padding8)
        }
        .hSetScrollBounce(to: true)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
