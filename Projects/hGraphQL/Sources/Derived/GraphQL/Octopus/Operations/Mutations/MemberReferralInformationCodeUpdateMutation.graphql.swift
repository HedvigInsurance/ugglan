// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberReferralInformationCodeUpdateMutation: GraphQLMutation {
    public static let operationName: String = "MemberReferralInformationCodeUpdate"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation MemberReferralInformationCodeUpdate($code: String!) { memberReferralInformationCodeUpdate(code: $code) { __typename userError { __typename message } } }"#
      ))

    public var code: String

    public init(code: String) {
      self.code = code
    }

    @_spi(Unsafe) public var __variables: Variables? { ["code": code] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("memberReferralInformationCodeUpdate", MemberReferralInformationCodeUpdate.self, arguments: ["code": .variable("code")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberReferralInformationCodeUpdateMutation.Data.self
      ] }

      /// Update the personal invite code for the current member.
      ///
      /// This can be personalised to take the original, rather random code like 'OWID23KS' and turn it into
      /// something more appealing like 'COWABUNGA'.
      public var memberReferralInformationCodeUpdate: MemberReferralInformationCodeUpdate { __data["memberReferralInformationCodeUpdate"] }

      /// MemberReferralInformationCodeUpdate
      ///
      /// Parent Type: `MemberReferralInformationMutationOutput`
      nonisolated public struct MemberReferralInformationCodeUpdate: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberReferralInformationMutationOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("userError", UserError?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberReferralInformationCodeUpdateMutation.Data.MemberReferralInformationCodeUpdate.self
        ] }

        public var userError: UserError? { __data["userError"] }

        /// MemberReferralInformationCodeUpdate.UserError
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
            MemberReferralInformationCodeUpdateMutation.Data.MemberReferralInformationCodeUpdate.UserError.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}