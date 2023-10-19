import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct UgglanState: StateProtocol {
    var selectedTabIndex: Int = 0
    var isDemoMode: Bool = false
    init() {}
}

enum UgglanAction: ActionProtocol {
    case setSelectedTabIndex(index: Int)
    case makeTabActive(deeplink: DeepLink)
    case showLoggedIn
    case openChat
    case closeChat
    case dismissScreen

    case setIsDemoMode(to: Bool)
}

final class UgglanStore: StateStore<UgglanState, UgglanAction> {
    @Inject var giraffe: hGiraffe

    override func effects(
        _ getState: @escaping () -> UgglanState,
        _ action: UgglanAction
    ) -> FiniteSignal<UgglanAction>? {

        return nil
    }

    override func reduce(_ state: UgglanState, _ action: UgglanAction) -> UgglanState {
        var newState = state

        switch action {
        case let .setSelectedTabIndex(tabIndex):
            newState.selectedTabIndex = tabIndex
        case let .setIsDemoMode(to):
            newState.isDemoMode = to
        default:
            break
        }

        return newState
    }
}
