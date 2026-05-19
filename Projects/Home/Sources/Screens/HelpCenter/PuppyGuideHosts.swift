@preconcurrency import HedvigShared
import SwiftUI
import hCoreUI

struct PuppyGuideListHost: UIViewControllerRepresentable {
    weak var router: NavigationRouter?

    func makeUIViewController(context: Context) -> UIViewController {
        let bridge = SwipeBackBridge()
        let composeVC = PuppyGuideViewControllersKt.PuppyGuideViewController(
            onNavigateUp: { [weak router] in
                DispatchQueue.main.async { router?.pop() }
            },
            onNavigateToArticle: { [weak router] storyName in
                DispatchQueue.main.async {
                    router?.push(PuppyGuideRoute.article(storyName: storyName))
                }
            },
            swipeBackController: bridge,
            onScrollOffsetChanged: { [bridge] offsetDp in
                DispatchQueue.main.async {
                    bridge.setScrollOffset(CGFloat(offsetDp.floatValue))
                }
            }
        )
        let host = SwipeBackToggleHostingController(child: composeVC)
        bridge.host = host
        return host
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct PuppyArticleHost: UIViewControllerRepresentable {
    let storyName: String
    weak var router: NavigationRouter?

    func makeUIViewController(context: Context) -> UIViewController {
        let bridge = SwipeBackBridge()
        let composeVC = PuppyGuideViewControllersKt.PuppyArticleViewController(
            storyName: storyName,
            navigateUp: { [weak router] in
                DispatchQueue.main.async { router?.pop() }
            },
            swipeBackController: bridge,
            onScrollOffsetChanged: { [bridge] offsetDp in
                DispatchQueue.main.async {
                    bridge.setScrollOffset(CGFloat(offsetDp.floatValue))
                }
            }
        )
        let host = SwipeBackToggleHostingController(child: composeVC)
        bridge.host = host
        return host
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
