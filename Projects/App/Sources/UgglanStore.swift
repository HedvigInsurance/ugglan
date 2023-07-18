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
    var isDemoMode: Bool = false
    var memberDetails: MemberDetails?

    init() {
        UNUserNotificationCenter.current()
            .getNotificationSettings { settings in
                let store: UgglanStore = globalPresentableStoreContainer.get()
                store.send(.setPushNotificationStatus(status: settings.authorizationStatus.rawValue))
            }
    }

    func pushNotificationCurrentStatus() -> UNAuthorizationStatus {
        if let status = pushNotificationStatus, let status = UNAuthorizationStatus(rawValue: status) {
            return status
        }
        return .notDetermined
    }

}

enum UgglanAction: ActionProtocol {
    case setSelectedTabIndex(index: Int)
    case makeTabActive(deeplink: DeepLink)
    case showLoggedIn
    case openChat
    case dismissScreen
    case sendAccountDeleteRequest(details: MemberDetails)
    case businessModelDetail
    case aboutBusinessModel
    case setPushNotificationStatus(status: Int?)
    case setIsDemoMode(to: Bool)
    case deleteAccount(details: MemberDetails)
    case setMemberDetails(details: MemberDetails?)
    case fetchMemberDetails
}

final class UgglanStore: StateStore<UgglanState, UgglanAction> {
    @Inject var giraffe: hGiraffe

    override func effects(
        _ getState: @escaping () -> UgglanState,
        _ action: UgglanAction
    ) -> FiniteSignal<UgglanAction>? {
        switch action {
        case .fetchMemberDetails:
            let query = GiraffeGraphQL.MemberDetailsQuery()
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.giraffe.client
                    .fetch(
                        query: query,
                        cachePolicy: .returnCacheDataElseFetch
                    )
                    .compactMap(on: .main) { details in
                        let details = MemberDetails(memberData: details.member)
                        callback(.value(.setMemberDetails(details: details)))
                    }
                return disposeBag
            }
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
        case let .setIsDemoMode(to):
            newState.isDemoMode = to
        case let .setMemberDetails(details):
            newState.memberDetails = details ?? MemberDetails(id: "", firstName: "", lastName: "", phone: "", email: "")
        default:
            break
        }

        return newState
    }
}
