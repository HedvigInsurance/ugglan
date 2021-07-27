import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public struct OfferState: StateProtocol {
	var hasSignedQuotes = false
	var ids: [String] = []

	public init() {}
}

public enum OfferAction: ActionProtocol {
	case didSign
	case openChat
	case query

	#if compiler(<5.5)
		public func encode(to encoder: Encoder) throws {
			#warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
			fatalError()
		}

		public init(
			from decoder: Decoder
		) throws {
			#warning("Waiting for automatic codable conformance from Swift 5.5, remove this when we have upgraded XCode")
			fatalError()
		}
	#endif
}

public final class OfferStore: StateStore<OfferState, OfferAction> {
	@Inject var client: ApolloClient
	@Inject var store: ApolloStore

	func query(for state: State) -> GraphQL.QuoteBundleQuery {
		GraphQL.QuoteBundleQuery(
			ids: state.ids,
			locale: Localization.Locale.currentLocale.asGraphQLLocale()
		)
	}

	override public func effects(_ getState: () -> State, _ action: Action) -> Future<Action>? {
        switch action {
        case .didSign:
            Analytics.track(
                "QUOTES_SIGNED",
                properties: [
                    "quoteIds": getState().ids
                ]
            )
            return nil
        default:
            return nil
        }
	}

	override public func reduce(_ state: OfferState, _ action: OfferAction) -> OfferState {
		var newState = state

		switch action {
        case .didSign:
			newState.hasSignedQuotes = true
		default:
			break
		}

		return newState
	}
}

extension OfferStore {
    enum SignEvent {
        case swedishBankId(
            autoStartToken: String,
            subscription: CoreSignal<Plain, GraphQL.SignStatusSubscription.Data>
        )
        case simpleSign(subscription: CoreSignal<Plain, GraphQL.SignStatusSubscription.Data>)
        case done
        case failed
    }

    func signQuotes() -> Signal<SignEvent> {
        let subscription = client.subscribe(subscription: GraphQL.SignStatusSubscription())
        let bag = DisposeBag()

        bag += subscription.map { $0.signStatus?.status?.signState == .completed }.filter(predicate: { $0 })
            .distinct()
            .onValue({ _ in
                self.send(.didSign)
            })

        return Signal { callback in
            
            self.client.perform(mutation: GraphQL.SignOrApproveQuotesMutation(ids: self.state.ids))
                .onResult { result in
                    switch result {
                    case .failure:
                        callback(SignEvent.failed)
                    case let .success(data):
                        if let signQuoteReponse = data.signOrApproveQuotes.asSignQuoteResponse {
                            if signQuoteReponse.signResponse.asFailedToStartSign != nil {
                                callback(SignEvent.failed)
                            } else if let session = signQuoteReponse
                                .signResponse
                                .asSwedishBankIdSession
                            {
                                callback(SignEvent.swedishBankId(
                                    autoStartToken: session.autoStartToken
                                        ?? "",
                                    subscription: subscription
                                ))
                            } else if signQuoteReponse.signResponse.asSimpleSignSession != nil {
                                callback(SignEvent.simpleSign(
                                    subscription: subscription
                                ))
                            }
                        } else if let approvedResponse = data.signOrApproveQuotes.asApproveQuoteResponse
                        {
                            if approvedResponse.approved == true {
                                self.send(.didSign)
                                callback(SignEvent.done)
                            }
                        }

                        callback(SignEvent.failed)
                    }
                }
            
            
            return bag
        }
    }
}
