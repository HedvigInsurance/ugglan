import Combine
import SwiftUI
import hCoreUI

/// Used in demo mode, previews and Example apps, where the shared Kotlin puppy guide isn't linked.
/// The entry point stays hidden; the screens are an empty placeholder.
public final class PuppyGuideClientDemo: PuppyGuideClient {
    public init() {}

    public func observeEntryPlacement(
        _ onChange: @escaping @MainActor (PuppyGuideEntryPlacement?) -> Void
    ) -> AnyCancellable {
        onChange(nil)
        return AnyCancellable {}
    }

    public func makeGuideViewController(
        onNavigateUp: @escaping @MainActor () -> Void,
        onOpenArticle: @escaping @MainActor (_ storyName: String) -> Void
    ) -> UIViewController {
        UIHostingController(rootView: hBackgroundColor.primary.ignoresSafeArea())
    }

    public func makeArticleViewController(
        storyName: String,
        onNavigateUp: @escaping @MainActor () -> Void
    ) -> UIViewController {
        UIHostingController(rootView: hBackgroundColor.primary.ignoresSafeArea())
    }
}
