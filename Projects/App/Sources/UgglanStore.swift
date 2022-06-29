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
    public init() {}
}

public enum UgglanAction: ActionProtocol {
    case setSelectedTabIndex(index: Int)
    case makeTabActive(deeplink: DeepLink)
    case showLoggedIn
    case validateAuthToken
    case openClaims
    case exchangePaymentLink(link: String)
    case exchangePaymentToken(token: String)
    case exchangeFailed
    case didAcceptHonestyPledge
    case openChat
    case sendAccountDeleteRequest(details: MemberDetails)
}

public final class UgglanStore: StateStore<UgglanState, UgglanAction> {
    @Inject var client: ApolloClient

    private func performTokenExchange(with token: String) -> FiniteSignal<UgglanAction> {
        return
            client.perform(
                mutation: GraphQL.ExchangeTokenMutation(
                    exchangeToken: token.removingPercentEncoding ?? ""
                )
            )
            .valueThenEndSignal
            .atValue(on: .main) { _ in

            }
            .delay(by: 0.25)
            .compactMap(on: .main) { response in
                guard
                    let token = response.exchangeToken
                        .asExchangeTokenSuccessResponse?
                        .token
                else { return .exchangeFailed }

                ApplicationState.preserveState(.impersonation)
                UIApplication.shared.appDelegate.logout(token: token)
                return nil
            }
    }

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

            return performTokenExchange(with: exchangeToken)
        case let .exchangePaymentToken(token):
            return performTokenExchange(with: token)
        case .validateAuthToken:
            return client.fetch(query: GraphQL.MemberIdQuery())
                .valueThenEndSignal
                .atError(on: .main) { error in
                    print(error.localizedDescription)
                    ApplicationState.preserveState(.marketPicker)
                    UIApplication.shared.appDelegate.logout(token: nil)
                    let toast = Toast(
                        symbol: .icon(hCoreUIAssets.infoShield.image),
                        body: "You have been logged out, please login again",
                        textColor: .black,
                        backgroundColor: .brand(.regularCaution)
                    )

                    Toasts.shared.displayToast(toast: toast)
                }
                .compactMap { $0.member.id }
                .compactMap(on: .main) { _ in
                    return nil
                }
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
