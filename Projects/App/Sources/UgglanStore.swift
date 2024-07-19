import Apollo
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct UgglanState: StateProtocol {
    var isDemoMode: Bool = false
    init() {}
}

enum UgglanAction: ActionProtocol {
    case setIsDemoMode(to: Bool)
}

final class UgglanStore: StateStore<UgglanState, UgglanAction> {
    override func effects(
        _ getState: @escaping () -> UgglanState,
        _ action: UgglanAction
    ) async {}

    override func reduce(_ state: UgglanState, _ action: UgglanAction) -> UgglanState {
        var newState = state

        switch action {
        case let .setIsDemoMode(to):
            newState.isDemoMode = to
        }

        return newState
    }
}
