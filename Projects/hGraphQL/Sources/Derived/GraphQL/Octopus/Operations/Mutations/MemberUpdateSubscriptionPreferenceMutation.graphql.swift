// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberUpdateSubscriptionPreferenceMutation: GraphQLMutation {
    public static let operationName: String = "MemberUpdateSubscriptionPreference"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation MemberUpdateSubscriptionPreference($subscribe: Boolean) { memberUpdateSubscriptionPreference(subscribe: $subscribe) { __typename message } }"#
      ))

    public var subscribe: GraphQLNullable<Bool>

    public init(subscribe: GraphQLNullable<Bool>) {
      self.subscribe = subscribe
    }

    @_spi(Unsafe) public var __variables: Variables? { ["subscribe": subscribe] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("memberUpdateSubscriptionPreference", MemberUpdateSubscriptionPreference?.self, arguments: ["subscribe": .variable("subscribe")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberUpdateSubscriptionPreferenceMutation.Data.self
      ] }

      public var memberUpdateSubscriptionPreference: MemberUpdateSubscriptionPreference? { __data["memberUpdateSubscriptionPreference"] }

      /// MemberUpdateSubscriptionPreference
      ///
      /// Parent Type: `UserError`
      nonisolated public struct MemberUpdateSubscriptionPreference: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UserError }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("message", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberUpdateSubscriptionPreferenceMutation.Data.MemberUpdateSubscriptionPreference.self
        ] }

        public var message: String { __data["message"] }
      }
    }
  }

}