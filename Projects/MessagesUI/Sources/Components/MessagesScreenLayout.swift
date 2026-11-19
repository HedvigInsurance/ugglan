import SwiftUI
import hCore
import hCoreUI

/// Shared chrome of the Messages screens, matching the chat Inbox: the standard white navigation bar with a centred
/// title, optional trailing buttons, and the scrolling `hForm` content.
struct MessagesScreenLayout<Trailing: ToolbarContent, Content: View>: View {
    let title: String
    let trailing: () -> Trailing
    let content: () -> Content
    private let showsTrailing: Bool

    init(
        title: String,
        @ToolbarContentBuilder trailing: @escaping () -> Trailing,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(title: title, trailing: trailing, showsTrailing: true, content: content)
    }

    fileprivate init(
        title: String,
        trailing: @escaping () -> Trailing,
        showsTrailing: Bool,
        content: @escaping () -> Content
    ) {
        self.title = title
        self.trailing = trailing
        self.showsTrailing = showsTrailing
        self.content = content
    }

    var body: some View {
        hForm {
            content()
                .padding(.top, .padding8)
        }
        .hSetScrollBounce(to: true)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if showsTrailing {
                trailing()
            }
        }
    }
}

extension MessagesScreenLayout where Trailing == ToolbarItem<Void, EmptyView> {
    /// No trailing buttons; nothing is added to the bar, so iOS 26 draws no empty glass item.
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.init(
            title: title,
            trailing: { ToolbarItem(placement: .topBarTrailing) { EmptyView() } },
            showsTrailing: false,
            content: content
        )
    }
}
