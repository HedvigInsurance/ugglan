import Flow
import Foundation
import hCore
import Presentation
import UIKit

public enum ContractFilter {
    case terminated
    case active
}

public struct Contracts {
    let filter: ContractFilter
    public static var openFreeTextChatHandler: (_ viewController: UIViewController) -> Void = { _ in }
    public init(filter: ContractFilter = .active) {
        self.filter = filter
    }
}

extension Contracts: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()

        if filter == .active {
            viewController.title = L10n.InsurancesTab.title
            viewController.installChatButton()
        }

        let bag = DisposeBag()

        bag += viewController.install(ContractTable(
            presentingViewController: viewController,
            filter: filter
        ))

        return (viewController, bag)
    }
}

extension Contracts: Tabable {
    public func tabBarItem() -> UITabBarItem {
        UITabBarItem(
            title: L10n.InsurancesTab.title,
            image: Asset.tab.image,
            selectedImage: Asset.tabActive.image
        )
    }
}
