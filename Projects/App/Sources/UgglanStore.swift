import Apollo
import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct UgglanState: StateProtocol {
    var isDemoMode: Bool = false
    init() {}
}

enum UgglanAction: ActionProtocol {
    case setIsDemoMode(to: Bool)
}

final class UgglanStore: StateStore<UgglanState, UgglanAction> {
    override func effects(
        _: @escaping () -> UgglanState,
        _: UgglanAction
    ) async {}

    override func reduce(_ state: UgglanState, _ action: UgglanAction) async -> UgglanState {
        var newState = state

        switch action {
        case let .setIsDemoMode(to):
            newState.isDemoMode = to
        }

        return newState
    }
}
