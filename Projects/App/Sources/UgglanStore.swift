import Apollo
import Flow
import Foundation
import Offer
import Presentation
import UIKit
import hCore
import hGraphQL

public struct UgglanState: StateProtocol {
    var selectedTabIndex: Int = 0
    public init() {}
}

public enum UgglanAction: ActionProtocol {
    case setSelectedTabIndex(index: Int)
    case makeTabActive(deeplink: DeepLink)
    case showLoggedIn
    case openClaims
    case exchangePaymentLink(link: String)
    case exchangeFailed
    case didAcceptHonestyPledge
    case openChat
}

public final class UgglanStore: StateStore<UgglanState, UgglanAction> {
    @Inject var client: ApolloClient

    public override func effects(
        _ getState: @escaping () -> UgglanState,
        _ action: UgglanAction
    ) -> FiniteSignal<UgglanAction>? {
        switch action {
        case let .exchangePaymentLink(link):
            let afterHashbang = link.split(separator: "#").last
            let exchangeToken =
                afterHashbang?.replacingOccurrences(of: "exchange-token=", with: "")
                ?? ""

            return
                client.perform(
                    mutation: GraphQL.ExchangeTokenMutation(
                        exchangeToken: exchangeToken.removingPercentEncoding ?? ""
                    )
                )
                .map(on: .main) { response in
                    guard
                        let token = response.exchangeToken
                            .asExchangeTokenSuccessResponse?
                            .token
                    else { return .exchangeFailed }

                    globalPresentableStoreContainer.deletePersistanceContainer()
                    globalPresentableStoreContainer = PresentableStoreContainer()

                    UIApplication.shared.appDelegate.setToken(token)

                    return .showLoggedIn
                }
                .valueThenEndSignal
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
        case .openClaims:
            break
        default:
            break
        }

        return newState
    }
}
