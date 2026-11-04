// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberUpdateContactInfoMutation: GraphQLMutation {
    public static let operationName: String = "MemberUpdateContactInfo"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation MemberUpdateContactInfo($input: MemberUpdateContactInfoInput!) { memberUpdateContactInfo(input: $input) { __typename member { __typename email phoneNumber } userError { __typename message } } }"#
      ))

    public var input: MemberUpdateContactInfoInput

    public init(input: MemberUpdateContactInfoInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("memberUpdateContactInfo", MemberUpdateContactInfo.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberUpdateContactInfoMutation.Data.self
      ] }

      /// Mutation that updates member email and phone number, or confirms them if they have not changed.
      public var memberUpdateContactInfo: MemberUpdateContactInfo { __data["memberUpdateContactInfo"] }

      /// MemberUpdateContactInfo
      ///
      /// Parent Type: `MemberMutationOutput`
      nonisolated public struct MemberUpdateContactInfo: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberMutationOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("member", Member?.self),
          .field("userError", UserError?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberUpdateContactInfoMutation.Data.MemberUpdateContactInfo.self
        ] }

        public var member: Member? { __data["member"] }
        public var userError: UserError? { __data["userError"] }

        /// MemberUpdateContactInfo.Member
        ///
        /// Parent Type: `Member`
        nonisolated public struct Member: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Member }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("email", String.self),
            .field("phoneNumber", String?.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MemberUpdateContactInfoMutation.Data.MemberUpdateContactInfo.Member.self
          ] }

          public var email: String { __data["email"] }
          public var phoneNumber: String? { __data["phoneNumber"] }
        }

        /// MemberUpdateContactInfo.UserError
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
            MemberUpdateContactInfoMutation.Data.MemberUpdateContactInfo.UserError.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}