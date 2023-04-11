import Apollo
import Flow
import Foundation
import Offer
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct UgglanState: StateProtocol {
    var selectedTabIndex: Int = 0
    var pushNotificationStatus: Int?

    public init() {}

    func askForPushNotificationPermission() -> Bool {
        if let status = pushNotificationStatus, let status = UNAuthorizationStatus(rawValue: status),
            status != .notDetermined
        {
            return false
        }
        return true
    }
}

public enum UgglanAction: ActionProtocol {
    case setSelectedTabIndex(index: Int)
    case makeTabActive(deeplink: DeepLink)
    case showLoggedIn
    case openChat
    case sendAccountDeleteRequest(details: MemberDetails)
    case businessModelDetail
    case aboutBusinessModel
    case setPushNotificationStatus(status: Int?)
}

public final class UgglanStore: StateStore<UgglanState, UgglanAction> {
    @Inject var giraffe: hGiraffe

    public override func effects(
        _ getState: @escaping () -> UgglanState,
        _ action: UgglanAction
    ) -> FiniteSignal<UgglanAction>? {
        switch action {
        default:
            break
        }

        return nil
    }

    public override func reduce(_ state: UgglanState, _ action: UgglanAction) -> UgglanState {
        var newState = state

        switch action {
        case let .setSelectedTabIndex(tabIndex):
            newState.selectedTabIndex = tabIndex
        case let .setPushNotificationStatus(status):
            newState.pushNotificationStatus = status
        default:
            break
        }

        return newState
    }
}
