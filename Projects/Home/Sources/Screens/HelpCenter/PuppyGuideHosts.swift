import SwiftUI
import hCore
import hCoreUI

struct PuppyGuideListHost: UIViewControllerRepresentable {
    weak var router: NavigationRouter?
    @Inject private var puppyGuideClient: PuppyGuideClient

    func makeUIViewController(context: Context) -> UIViewController {
        puppyGuideClient.makeGuideViewController(
            onNavigateUp: { [weak router] in router?.pop() },
            onOpenArticle: { [weak router] storyName in
                router?.push(PuppyGuideRoute.article(storyName: storyName))
            }
        )
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct PuppyArticleHost: UIViewControllerRepresentable {
    let storyName: String
    weak var router: NavigationRouter?
    @Inject private var puppyGuideClient: PuppyGuideClient

    func makeUIViewController(context: Context) -> UIViewController {
        puppyGuideClient.makeArticleViewController(
            storyName: storyName,
            onNavigateUp: { [weak router] in router?.pop() }
        )
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
