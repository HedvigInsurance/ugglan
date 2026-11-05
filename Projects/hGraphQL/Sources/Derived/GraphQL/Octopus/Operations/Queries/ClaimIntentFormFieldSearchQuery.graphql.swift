// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimIntentFormFieldSearchQuery: GraphQLQuery {
    public static let operationName: String = "ClaimIntentFormFieldSearch"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ClaimIntentFormFieldSearch($input: ClaimIntentFormFieldSearchInput!) { claimIntentFormFieldSearch(input: $input) { __typename options { __typename imageUrl subtitle title value isCustomSearchEntry } suggestedQuery } }"#
      ))

    public var input: ClaimIntentFormFieldSearchInput

    public init(input: ClaimIntentFormFieldSearchInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("claimIntentFormFieldSearch", ClaimIntentFormFieldSearch.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimIntentFormFieldSearchQuery.Data.self
      ] }

      public var claimIntentFormFieldSearch: ClaimIntentFormFieldSearch { __data["claimIntentFormFieldSearch"] }

      /// ClaimIntentFormFieldSearch
      ///
      /// Parent Type: `ClaimIntentFormFieldSearchOutput`
      nonisolated public struct ClaimIntentFormFieldSearch: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentFormFieldSearchOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("options", [Option].self),
          .field("suggestedQuery", String?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimIntentFormFieldSearchQuery.Data.ClaimIntentFormFieldSearch.self
        ] }

        public var options: [Option] { __data["options"] }
        /// If present, this suggests a different query to use.
        /// Typically when there are no options, this could contain a fix for a possible query typo.
        public var suggestedQuery: String? { __data["suggestedQuery"] }

        /// ClaimIntentFormFieldSearch.Option
        ///
        /// Parent Type: `ClaimIntentStepContentFormFieldOption`
        nonisolated public struct Option: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntentStepContentFormFieldOption }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("imageUrl", String?.self),
            .field("subtitle", String?.self),
            .field("title", String.self),
            .field("value", OctopusGraphQL.ClaimIntentStepContentFormFieldValue.self),
            .field("isCustomSearchEntry", Bool.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ClaimIntentFormFieldSearchQuery.Data.ClaimIntentFormFieldSearch.Option.self
          ] }

          public var imageUrl: String? { __data["imageUrl"] }
          public var subtitle: String? { __data["subtitle"] }
          public var title: String { __data["title"] }
          public var value: OctopusGraphQL.ClaimIntentStepContentFormFieldValue { __data["value"] }
          public var isCustomSearchEntry: Bool { __data["isCustomSearchEntry"] }
        }
      }
    }
  }

}