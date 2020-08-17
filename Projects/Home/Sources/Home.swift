import Foundation
import Flow
import Presentation
import UIKit
import hCore
import hCoreUI
import Form

public struct Home {
    public init() {}
}

extension Home: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = "test"
        let bag = DisposeBag()
        
        let form = FormView()
        
        bag += viewController.install(form)
        
        bag += form.didMoveToWindowSignal.onValue {
            ContextGradient.currentOption = .home
        }
        
        return (viewController, bag)
    }
}


extension Home: Tabable {
    public func tabBarItem() -> UITabBarItem {
        return UITabBarItem(
            title: L10n.HomeTab.title,
            image: Asset.tab.image,
            selectedImage: Asset.tabSelected.image
        )
    }
}
