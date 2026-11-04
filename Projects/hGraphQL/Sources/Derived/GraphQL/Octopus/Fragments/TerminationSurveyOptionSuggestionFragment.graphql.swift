// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct TerminationSurveyOptionSuggestionFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment TerminationSurveyOptionSuggestionFragment on TerminationFlowSurveyOptionSuggestion { __typename type description actionText url }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowSurveyOptionSuggestion }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("type", GraphQLEnum<OctopusGraphQL.TerminationFlowSurveyOptionSuggestionType>.self),
      .field("description", String.self),
      .field("actionText", String?.self),
      .field("url", String?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      TerminationSurveyOptionSuggestionFragment.self
    ] }

    public var type: GraphQLEnum<OctopusGraphQL.TerminationFlowSurveyOptionSuggestionType> { __data["type"] }
    public var description: String { __data["description"] }
    public var actionText: String? { __data["actionText"] }
    public var url: String? { __data["url"] }
  }

}