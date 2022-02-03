import Apollo
import Flow
import Foundation
import Offer
import Presentation
import UIKit
import hCore
import hGraphQL

public struct ForeverState: StateProtocol {
    public var hasSeenFebruaryCampaign: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenFebruaryCampaign, forKey: Self.hasSeenFebruaryCampaignKey)
            UserDefaults.standard.synchronize()
        }
    }

    fileprivate static var hasSeenFebruaryCampaignKey: String {
        "ForeverFebruaryCampaign-hasBeenSeen"
    }

    public init() {
        self.hasSeenFebruaryCampaign = false
    }
}

public enum ForeverAction: ActionProtocol {
    case hasSeenFebruaryCampaign(value: Bool)
}

public final class ForeverStore: StateStore<ForeverState, ForeverAction> {
    public override func effects(
        _ getState: @escaping () -> ForeverState,
        _ action: ForeverAction
    ) -> FiniteSignal<ForeverAction>? {
        return nil
    }

    public override func reduce(_ state: ForeverState, _ action: ForeverAction) -> ForeverState {
        var newState = state

        switch action {
        case let .hasSeenFebruaryCampaign(hasSeenFebruaryCampaign):
            newState.hasSeenFebruaryCampaign = hasSeenFebruaryCampaign
        }

        return newState
    }
}
