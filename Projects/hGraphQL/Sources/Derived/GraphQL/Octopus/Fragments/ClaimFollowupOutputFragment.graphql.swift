// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct ClaimFollowupOutputFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment ClaimFollowupOutputFragment on ClaimFollowupOutput { __typename followup { __typename ...ClaimFollowupFragment } userError { __typename message } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowupOutput }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("followup", Followup?.self),
      .field("userError", UserError?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ClaimFollowupOutputFragment.self
    ] }

    public var followup: Followup? { __data["followup"] }
    public var userError: UserError? { __data["userError"] }

    /// Followup
    ///
    /// Parent Type: `ClaimFollowup`
    nonisolated public struct Followup: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ClaimFollowup }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ClaimFollowupFragment.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimFollowupOutputFragment.Followup.self,
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

    /// UserError
    ///
    /// Parent Type: `UserError`
    nonisolated public struct UserError: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UserError }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("message", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ClaimFollowupOutputFragment.UserError.self
      ] }

      public var message: String { __data["message"] }
    }
  }

}