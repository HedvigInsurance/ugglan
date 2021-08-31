import Flow
import Foundation
import Presentation
import UIKit
import hCore

public indirect enum ContractFilter {
    var displaysActiveContracts: Bool {
        switch self {
        case .terminated: return false
        case .active: return true
        case .none: return false
        }
    }

    var displaysTerminatedContracts: Bool {
        switch self {
        case .terminated: return true
        case .active: return false
        case .none: return false
        }
    }

    var emptyFilter: ContractFilter {
        switch self {
        case let .terminated(ifEmpty): return ifEmpty
        case let .active(ifEmpty): return ifEmpty
        case .none: return .none
        }
    }

    case terminated(ifEmpty: ContractFilter)
    case active(ifEmpty: ContractFilter)
    case none
}

public struct Contracts {
    let filter: ContractFilter
    public init(filter: ContractFilter = .active(ifEmpty: .terminated(ifEmpty: .none))) { self.filter = filter }
}

public enum ContractsResult {
    case movingFlow
    case openFreeTextChat
}

extension Contracts: Presentable {
    public func materialize() -> (UIViewController, Signal<ContractsResult>) {
        let viewController = UIViewController()

        let store: ContractStore = get()

        if filter.displaysActiveContracts {
            viewController.title = L10n.InsurancesTab.title
            viewController.installChatButton()
        }

        let bag = DisposeBag()

        bag += viewController.install(
            ContractTable(presentingViewController: viewController, filter: filter)
        )

        return (
            viewController,
            Signal { callback in
                bag += store.actionSignal.onValue {
                    if $0 == .goToMovingFlow {
                        callback(.movingFlow)
                    }
                }

                return bag
            }
        )
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
