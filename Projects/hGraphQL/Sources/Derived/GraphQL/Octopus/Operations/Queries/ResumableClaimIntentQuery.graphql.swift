// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ResumableClaimIntentQuery: GraphQLQuery {
    public static let operationName: String = "ResumableClaimIntent"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ResumableClaimIntent { currentMember { __typename resumableClaimIntent { __typename id createdAt displayName } } }"#
      ))

    public init() {}

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("currentMember", CurrentMember.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ResumableClaimIntentQuery.Data.self
      ] }

      /// Gets the currently authenticated member. This is the only valid way to query a `Member` type, and it is based
      /// on the input Authorization header.
      public var currentMember: CurrentMember { __data["currentMember"] }

      /// CurrentMember
      ///
      /// Parent Type: `Member`
      nonisolated public struct CurrentMember: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Member }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("resumableClaimIntent", ResumableClaimIntent?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ResumableClaimIntentQuery.Data.CurrentMember.self
        ] }

        /// Returns the most recent claim intent for this member, that can be "resumed" by querying `ClaimIntent.previousSteps`.
        ///
        /// Will return `null` if the server considers it too old to be resumed.
        ///
        /// Pass `resume: true` when the member actually continues the draft, rather than only being shown that one
        /// exists. Doing so records the moment as the current step's start, so the time the draft sat untouched is
        /// not counted as time the member spent answering it.
        public var resumableClaimIntent: ResumableClaimIntent? { __data["resumableClaimIntent"] }

        /// CurrentMember.ResumableClaimIntent
        ///
        /// Parent Type: `ClaimIntent`
        nonisolated public struct ResumableClaimIntent: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimIntent }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", OctopusGraphQL.ID.self),
            .field("createdAt", OctopusGraphQL.DateTime.self),
            .field("displayName", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ResumableClaimIntentQuery.Data.CurrentMember.ResumableClaimIntent.self
          ] }

          public var id: OctopusGraphQL.ID { __data["id"] }
          /// The time this was started.
          public var createdAt: OctopusGraphQL.DateTime { __data["createdAt"] }
          /// A short summary of the contents of this flow. Null when the flow is completely new (typically pre triage).
          public var displayName: String? { __data["displayName"] }
        }
      }
    }
  }

}