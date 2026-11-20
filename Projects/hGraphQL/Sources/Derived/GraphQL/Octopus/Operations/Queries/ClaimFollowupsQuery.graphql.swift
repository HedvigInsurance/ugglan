// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimFollowupsQuery: GraphQLQuery {
    public static let operationName: String = "ClaimFollowups"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query ClaimFollowups { currentMember { __typename claimFollowups { __typename ...ClaimFollowupFragment } } }"#,
        fragments: [ClaimFollowupFragment.self]
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
        ClaimFollowupsQuery.Data.self
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
          .field("claimFollowups", [ClaimFollowup].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ClaimFollowupsQuery.Data.CurrentMember.self
        ] }

        /// The member's follow-ups, oldest first; only that claim's when claimId is given.
        public var claimFollowups: [ClaimFollowup] { __data["claimFollowups"] }

        /// CurrentMember.ClaimFollowup
        ///
        /// Parent Type: `ClaimFollowup`
        nonisolated public struct ClaimFollowup: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowup }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(ClaimFollowupFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            ClaimFollowupsQuery.Data.CurrentMember.ClaimFollowup.self,
            ClaimFollowupFragment.self
          ] }

          public var id: OctopusGraphQL.ID { __data["id"] }
          public var claimId: OctopusGraphQL.ID { __data["claimId"] }
          public var status: GraphQLEnum<OctopusGraphQL.ClaimFollowupStatus> { __data["status"] }
          public var questions: [Question] { __data["questions"] }

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var claimFollowupFragment: ClaimFollowupFragment { _toFragment() }
          }

          public typealias Question = ClaimFollowupFragment.Question
        }
      }
    }
  }

}