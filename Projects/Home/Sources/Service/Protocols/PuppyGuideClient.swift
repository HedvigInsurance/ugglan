import Combine
import UIKit

/// Where the Help Center shows the puppy guide entry, as decided by the shared (Kotlin) layer.
public enum PuppyGuideEntryPlacement: Sendable {
    case fullCard
    case quickAction
}

/// The puppy guide screens are built in the shared Kotlin (Compose) code. Home only talks to them through this
/// protocol, so it doesn't have to link HedvigShared; the real implementation lives in App.
@MainActor
public protocol PuppyGuideClient {
    /// Calls `onChange` on the main actor whenever the entry point changes; `nil` hides it.
    /// Observation stops when the returned cancellable is cancelled or released.
    func observeEntryPlacement(_ onChange: @escaping @MainActor (PuppyGuideEntryPlacement?) -> Void) -> AnyCancellable

    func makeGuideViewController(
        onNavigateUp: @escaping @MainActor () -> Void,
        onOpenArticle: @escaping @MainActor (_ storyName: String) -> Void
    ) -> UIViewController

    func makeArticleViewController(
        storyName: String,
        onNavigateUp: @escaping @MainActor () -> Void
    ) -> UIViewController
}
