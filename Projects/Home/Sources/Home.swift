import Flow
import Form
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

public struct Home {
    public init() {}
}

extension Home: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.HomeTab.title
        viewController.installChatButton()

        if #available(iOS 13.0, *) {
            let scrollEdgeAppearance = UINavigationBarAppearance()
            DefaultStyling.applyCommonNavigationBarStyling(scrollEdgeAppearance)
            scrollEdgeAppearance.configureWithTransparentBackground()
            scrollEdgeAppearance.largeTitleTextAttributes = scrollEdgeAppearance.largeTitleTextAttributes.merging([
                NSAttributedString.Key.foregroundColor: UIColor.clear,
            ], uniquingKeysWith: takeRight)

            viewController.navigationItem.scrollEdgeAppearance = scrollEdgeAppearance
        }

        let bag = DisposeBag()

        let form = FormView()
        bag += viewController.install(form)

        let titleSection = form.appendSection()
        let titleRow = RowView()
        titleRow.layoutMargins = UIEdgeInsets(
            top: 0,
            left: 24,
            bottom: 0,
            right: 24
        )
        titleRow.isLayoutMarginsRelativeArrangement = true
        titleSection.append(titleRow)

        bag += titleRow.append()

        bag += form.didMoveToWindowSignal.onValue {
            ContextGradient.currentOption = .home
        }

        return (viewController, bag)
    }
}

extension Home: Tabable {
    public func tabBarItem() -> UITabBarItem {
        UITabBarItem(
            title: L10n.HomeTab.title,
            image: Asset.tab.image,
            selectedImage: Asset.tabSelected.image
        )
    }
}
