import Foundation

public enum APIType: String, Codable {
	case personalInformation
	case houseInformation
	case createQuote
	case graphQLQuery
	case graphQLMutation
}

public struct hAPI: Codable {
	public let type: APIType
	public let data: APIData

	init?(
		api: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction.SelectActionDatum
			.Option.Api?
	) {
		guard let api = api else { return nil }

		if let api = api.asEmbarkApiGraphQlQuery {
			type = .graphQLQuery
			let next = api.data.next.map { hEmbarkLink(name: $0.name, label: $0.label) }
			data = .init(
				next: next,
				query: api.data.query,
				variables: api.data.variables.compactMap { .init(variable: $0) },
				results: api.data.queryResults.map { .init(result: $0) },
				errors: api.data.queryErrors.map { .init(error: $0) }
			)
		} else if let api = api.asEmbarkApiGraphQlMutation {
			type = .graphQLMutation
			let next = api.data.next.map { hEmbarkLink(name: $0.name, label: $0.label) }
			data = .init(
				next: next,
				query: api.data.mutation,
				variables: api.data.variables.compactMap { .init(variable: $0) },
				results: [],
				errors: []
			)
		} else {
			return nil
		}
	}

	init?(
		api: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkTextAction.TextActionDatum.Api?
	) {
		guard let api = api else { return nil }

		if let api = api.asEmbarkApiGraphQlQuery {
			type = .graphQLQuery
			let next = api.data.next.map { hEmbarkLink(name: $0.name, label: $0.label) }
			data = .init(
				next: next,
				query: api.data.query,
				variables: api.data.variables.compactMap {
					.init(variable: $0.fragments.apiVariablesFragment)
				},
				results: api.data.queryResults.map { .init(result: $0) },
				errors: api.data.queryErrors.map { .init(error: $0) }
			)
		} else if let api = api.asEmbarkApiGraphQlMutation {
			type = .graphQLMutation
			let next = api.data.next.map { hEmbarkLink(name: $0.name, label: $0.label) }
			data = .init(
				next: next,
				query: api.data.mutation,
				variables: api.data.variables.compactMap {
					.init(variable: $0.fragments.apiVariablesFragment)
				},
				results: [],
				errors: []
			)
		} else {
			return nil
		}
	}

	public struct APIData: Codable {
		public let next: hEmbarkLink?
		public let query: String
		public let variables: [Variables]
		public let results: [QueryResult]
		public let errors: [QueryError]
	}

	public enum VariableTypes: String, Codable {
		case single, generated, multiActionVariable
	}

	public struct Variables: Codable {
		public let type: VariableTypes
		public let key: String
		public let from: String?
		public let `as`: String?
		public let variables: [Variables]

		init?(
			variable: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction
				.SelectActionDatum.Option.Api.AsEmbarkApiGraphQlQuery.Datum.Variable
		) {
			if let variable = variable.asEmbarkApiGraphQlGeneratedVariable {
				self.init(generatedVariable: variable.fragments.apiGeneratedVariableFragment)
			} else if let variable = variable.asEmbarkApiGraphQlSingleVariable {
				self.init(singleVariable: variable.fragments.apiSingleVariableFragment)
			} else if let variable = variable.asEmbarkApiGraphQlMultiActionVariable {
				self.init(multiVariable: variable.fragments.apiMultiActionVariableFragment)
			} else {
				return nil
			}
		}

		init?(
			variable: GraphQL.ApiVariablesFragment
		) {
			if let variable = variable.asEmbarkApiGraphQlGeneratedVariable {
				self.init(generatedVariable: variable.fragments.apiGeneratedVariableFragment)
			} else if let variable = variable.asEmbarkApiGraphQlSingleVariable {
				self.init(singleVariable: variable.fragments.apiSingleVariableFragment)
			} else if let variable = variable.asEmbarkApiGraphQlMultiActionVariable {
				self.init(multiVariable: variable.fragments.apiMultiActionVariableFragment)
			} else {
				return nil
			}
		}

		init?(
			variable: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction
				.SelectActionDatum.Option.Api.AsEmbarkApiGraphQlMutation.Datum.Variable
		) {
			if let variable = variable.asEmbarkApiGraphQlGeneratedVariable {
				self.init(generatedVariable: variable.fragments.apiGeneratedVariableFragment)
			} else if let variable = variable.asEmbarkApiGraphQlSingleVariable {
				self.init(singleVariable: variable.fragments.apiSingleVariableFragment)
			} else if let variable = variable.asEmbarkApiGraphQlMultiActionVariable {
				self.init(multiVariable: variable.fragments.apiMultiActionVariableFragment)
			} else {
				return nil
			}
		}

		init(
			generatedVariable: GraphQL.ApiGeneratedVariableFragment
		) {
			type = .generated
			key = generatedVariable.key
			from = nil
			self.as = generatedVariable.storeAs
			variables = []
		}

		init(
			multiVariable: GraphQL.ApiMultiActionVariableFragment
		) {
			type = .generated
			key = multiVariable.key
			from = nil
			self.as = nil
			let generatedVariables = multiVariable.variables
				.compactMap {
					if let fragment = $0.fragments.apiGeneratedVariableFragment {
						return fragment
					} else {
						return nil
					}
				}
				.map {
					Variables.init(generatedVariable: $0)
				}

			let singleVariables = multiVariable.variables
				.compactMap {
					if let fragment = $0.fragments.apiGeneratedVariableFragment {
						return fragment
					} else {
						return nil
					}
				}
				.map {
					Variables.init(generatedVariable: $0)
				}

			variables = generatedVariables + singleVariables
		}

		init(
			singleVariable: GraphQL.ApiSingleVariableFragment
		) {
			type = .generated
			key = singleVariable.key
			from = nil
			self.as = nil
			variables = []
		}
	}

	public struct QueryResult: Codable {
		public let key: String?
		public let `as`: String?
		init(
			result: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction
				.SelectActionDatum.Option.Api.AsEmbarkApiGraphQlQuery.Datum.QueryResult
		) {
			self.key = result.key
			self.as = result.as
		}

		init(
			result: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkTextAction
				.TextActionDatum.Api.AsEmbarkApiGraphQlQuery.Datum.QueryResult
		) {
			self.key = result.key
			self.as = result.as
		}
	}

	public struct QueryError: Codable {
		public let contains: String?
		public let next: hEmbarkLink?
		init(
			error: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction
				.SelectActionDatum.Option.Api.AsEmbarkApiGraphQlQuery.Datum.QueryError
		) {
			contains = error.contains
			next = .init(name: error.next.name, label: error.next.label)
		}
		init(
			error: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkTextAction
				.TextActionDatum.Api.AsEmbarkApiGraphQlQuery.Datum.QueryError
		) {
			contains = error.contains
			next = .init(name: error.next.name, label: error.next.label)
		}
	}
}
