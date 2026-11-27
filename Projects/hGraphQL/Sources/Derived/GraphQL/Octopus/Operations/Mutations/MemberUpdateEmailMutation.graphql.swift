// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberUpdateEmailMutation: GraphQLMutation {
    public static let operationName: String = "MemberUpdateEmail"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation MemberUpdateEmail($input: MemberUpdateEmailInput!) { memberUpdateEmail(input: $input) { __typename member { __typename email } userError { __typename message } } }"#
      ))

    public var input: MemberUpdateEmailInput

    public init(input: MemberUpdateEmailInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("memberUpdateEmail", MemberUpdateEmail.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberUpdateEmailMutation.Data.self
      ] }

      @available(*, deprecated, message: "Use memberUpdateContactInfo instead")
      public var memberUpdateEmail: MemberUpdateEmail { __data["memberUpdateEmail"] }

      /// MemberUpdateEmail
      ///
      /// Parent Type: `MemberMutationOutput`
      nonisolated public struct MemberUpdateEmail: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberMutationOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("member", Member?.self),
          .field("userError", UserError?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberUpdateEmailMutation.Data.MemberUpdateEmail.self
        ] }

        public var member: Member? { __data["member"] }
        public var userError: UserError? { __data["userError"] }

        /// MemberUpdateEmail.Member
        ///
        /// Parent Type: `Member`
        nonisolated public struct Member: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Member }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("email", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MemberUpdateEmailMutation.Data.MemberUpdateEmail.Member.self
          ] }

          public var email: String { __data["email"] }
        }

        /// MemberUpdateEmail.UserError
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
            MemberUpdateEmailMutation.Data.MemberUpdateEmail.UserError.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}