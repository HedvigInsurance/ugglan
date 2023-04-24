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
    var pushNotificationStatus: Int?

    init() {
        UNUserNotificationCenter.current()
            .getNotificationSettings { settings in
                let store: UgglanStore = globalPresentableStoreContainer.get()
                store.send(.setPushNotificationStatus(status: settings.authorizationStatus.rawValue))
            }
    }

    func askForPushNotificationPermission() -> Bool {
        if let status = pushNotificationStatus, let status = UNAuthorizationStatus(rawValue: status),
            status != .notDetermined
        {
            return false
        }
        return true
    }
}

enum UgglanAction: ActionProtocol {
    case setSelectedTabIndex(index: Int)
    case makeTabActive(deeplink: DeepLink)
    case showLoggedIn
    case openChat
    case sendAccountDeleteRequest(details: MemberDetails)
    case businessModelDetail
    case aboutBusinessModel
    case setPushNotificationStatus(status: Int?)
}

final class UgglanStore: StateStore<UgglanState, UgglanAction> {
    override func effects(
        _ getState: @escaping () -> UgglanState,
        _ action: UgglanAction
    ) -> FiniteSignal<UgglanAction>? {
        switch action {
        default:
            break
        }

        return nil
    }

    override func reduce(_ state: UgglanState, _ action: UgglanAction) -> UgglanState {
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
