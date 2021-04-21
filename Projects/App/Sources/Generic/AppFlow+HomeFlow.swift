import Contracts
import Flow
import Foundation
import hCore
import hCoreUI
import Home
import Payment
import Presentation
import UIKit

struct HomeFlow: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let (viewController, disposable) = Home(sections: Contracts.getSections()).materialize()

        bag += disposable

        return (viewController, bag)
    }
}

extension HomeFlow: Tabable {
    public func tabBarItem() -> UITabBarItem {
        Home.tabBarItem()
    }
}

public extension Contracts {
    static func getSections() -> [HomeSection] {
        [
            HomeSection(
                title: L10n.HomeTab.editingSectionTitle,
                style: .vertical,
                children:
                [.init(
                    title: L10n.HomeTab.editingSectionChangeAddressLabel,
                    icon: hCoreUIAssets.apartment.image,
                    handler: { viewController in
                        viewController.present(MovingFlow())
                    }
                )]
            ),
        ]
    }
}
