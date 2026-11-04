// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct TerminationSurveyOptionFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment TerminationSurveyOptionFragment on TerminationFlowSurveyOption { __typename id title feedbackRequired suggestion { __typename ...TerminationSurveyOptionSuggestionFragment } redirection { __typename ...TerminationSurveyOptionRedirectionFragment } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowSurveyOption }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", OctopusGraphQL.ID.self),
      .field("title", String.self),
      .field("feedbackRequired", Bool.self),
      .field("suggestion", Suggestion?.self),
      .field("redirection", Redirection?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      TerminationSurveyOptionFragment.self
    ] }

    public var id: OctopusGraphQL.ID { __data["id"] }
    public var title: String { __data["title"] }
    public var feedbackRequired: Bool { __data["feedbackRequired"] }
    public var suggestion: Suggestion? { __data["suggestion"] }
    ///  Redirection to an alternative flow, replacing the sub option it was derived from. Only set when the query is sent with redirectionEnabled: true 
    public var redirection: Redirection? { __data["redirection"] }

    /// Suggestion
    ///
    /// Parent Type: `TerminationFlowSurveyOptionSuggestion`
    nonisolated public struct Suggestion: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowSurveyOptionSuggestion }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(TerminationSurveyOptionSuggestionFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TerminationSurveyOptionFragment.Suggestion.self,
        TerminationSurveyOptionSuggestionFragment.self
      ] }

      public var type: GraphQLEnum<OctopusGraphQL.TerminationFlowSurveyOptionSuggestionType> { __data["type"] }
      public var description: String { __data["description"] }
      public var actionText: String? { __data["actionText"] }
      public var url: String? { __data["url"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var terminationSurveyOptionSuggestionFragment: TerminationSurveyOptionSuggestionFragment { _toFragment() }
      }
    }

    /// Redirection
    ///
    /// Parent Type: `TerminationFlowSurveyOptionRedirection`
    nonisolated public struct Redirection: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.TerminationFlowSurveyOptionRedirection }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(TerminationSurveyOptionRedirectionFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        TerminationSurveyOptionFragment.Redirection.self,
        TerminationSurveyOptionRedirectionFragment.self
      ] }

      ///  Heading of the redirection 
      public var title: String { __data["title"] }
      ///  Body text explaining what the redirection offers 
      public var description: String { __data["description"] }
      ///  Determines which flow the member is redirected to 
      public var type: GraphQLEnum<OctopusGraphQL.TerminationFlowSurveyOptionRedirectionType> { __data["type"] }
      ///  Text for the button that starts the redirection 
      public var actionText: String { __data["actionText"] }
      ///  Optional illustration to show with the redirection 
      public var image: Image? { __data["image"] }

      public struct Fragments: FragmentContainer {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        public var terminationSurveyOptionRedirectionFragment: TerminationSurveyOptionRedirectionFragment { _toFragment() }
      }

      public typealias Image = TerminationSurveyOptionRedirectionFragment.Image
    }
  }

}