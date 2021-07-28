import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public struct OfferState: StateProtocol {
	var hasSignedQuotes = false
	var ids: [String] = []
	var swedishBankIDAutoStartToken: String? = nil
	var swedishBankIDStatusCode: String? = nil

	public init() {}
}

public enum OfferAction: ActionProtocol {
	case sign(event: SignEvent)
	case startSwedishBankIDSign(autoStartToken: String)
	case setSwedishBankID(statusCode: String)
	case startSign
	case set(ids: [String])
	case openChat
	case query

	public enum SignEvent: Codable {
		case swedishBankId
		case simpleSign
		case done
		case failed

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

	override public func effects(_ getState: () -> State, _ action: Action) -> FiniteSignal<Action>? {
		switch action {
		case let .sign(event):
			if event == .done {
				Analytics.track(
					"QUOTES_SIGNED",
					properties: [
						"quoteIds": getState().ids
					]
				)
			}
		case .startSign:
			return signQuotesEffect()
		default:
			return nil
		}

		return nil
	}

	override public func reduce(_ state: OfferState, _ action: OfferAction) -> OfferState {
		var newState = state

		switch action {
		case let .set(ids):
			newState.ids = ids
		case let .sign(event):
			if event == .done {
				newState.hasSignedQuotes = true
			}
		case let .startSwedishBankIDSign(autoStartToken):
			newState.swedishBankIDAutoStartToken = autoStartToken
		default:
			break
		}

		return newState
	}
}

extension OfferStore {
	func signQuotesEffect() -> FiniteSignal<Action> {
		let subscription = client.subscribe(subscription: GraphQL.SignStatusSubscription())
		let bag = DisposeBag()

		return FiniteSignal { callback in
			bag += subscription.map { $0.signStatus?.status?.signState == .completed }
				.filter(predicate: { $0 })
				.distinct()
				.onValue({ _ in
					callback(.value(.sign(event: OfferAction.SignEvent.done)))
				})

			bag += subscription.compactMap { $0.signStatus?.status?.collectStatus?.code }
				.distinct()
				.onValue({ code in
					callback(.value(.setSwedishBankID(statusCode: code)))
				})

			self.client.perform(mutation: GraphQL.SignOrApproveQuotesMutation(ids: self.state.ids))
				.onResult { result in
					switch result {
					case .failure:
						callback(.value(.sign(event: OfferAction.SignEvent.failed)))
					case let .success(data):
						if let signQuoteReponse = data.signOrApproveQuotes.asSignQuoteResponse {
							if signQuoteReponse.signResponse.asFailedToStartSign != nil {
								callback(
									.value(
										.sign(
											event: OfferAction.SignEvent
												.failed
										)
									)
								)
							} else if let session = signQuoteReponse
								.signResponse
								.asSwedishBankIdSession
							{
								callback(
									.value(
										.startSwedishBankIDSign(
											autoStartToken:
												session.autoStartToken
												?? ""
										)
									)
								)
							} else if signQuoteReponse.signResponse.asSimpleSignSession
								!= nil
							{
								callback(
									.value(
										.sign(
											event: OfferAction.SignEvent
												.simpleSign
										)
									)
								)
							}
						} else if let approvedResponse = data.signOrApproveQuotes
							.asApproveQuoteResponse
						{
							if approvedResponse.approved == true {
								callback(
									.value(.sign(event: OfferAction.SignEvent.done))
								)
							}
						}

						callback(.value(.sign(event: OfferAction.SignEvent.failed)))
					}
				}

			return bag
		}
	}
}
