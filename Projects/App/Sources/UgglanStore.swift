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
    var onboardingIdentifier: String? = nil
    public init() {}
}

public enum UgglanAction: ActionProtocol {
    case setSelectedTabIndex(index: Int)
    case makeTabActive(deeplink: DeepLink)
    case showLoggedIn
    case openClaims
    case exchangePaymentLink(link: String)
    case exchangePaymentToken(token: String)
    case exchangeFailed
    case didAcceptHonestyPledge
    case openChat
    case createOnboardingQuoteCart
    case setOnboardingIdentifier(id: String)
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

    private func getOnboardingQuoteCart() -> FiniteSignal<UgglanAction> {
        let locale = Localization.Locale.currentLocale
        return self.client
            .perform(
                mutation: GraphQL.CreateOnboardingQuoteCartMutation(
                    input: .init(market: locale.market.graphQL, locale: locale.rawValue)
                )
            )
            .map { data in
                return .setOnboardingIdentifier(id: data.onboardingQuoteCartCreate.id.displayValue)
            }
            .valueThenEndSignal
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
        case .createOnboardingQuoteCart:
            return getOnboardingQuoteCart()
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
        case let .setOnboardingIdentifier(id):
            newState.onboardingIdentifier = id
        default:
            break
        }

        return newState
    }
}

extension Localization.Locale.Market {
    var graphQL: GraphQL.Market {
        switch self {
        case .dk:
            return .denmark
        case .se:
            return .sweden
        case .no:
            return .norway
        default:
            return .__unknown("")
        }
    }
}
