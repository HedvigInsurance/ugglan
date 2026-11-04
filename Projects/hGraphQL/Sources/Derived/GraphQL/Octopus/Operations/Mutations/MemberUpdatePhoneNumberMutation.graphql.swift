// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberUpdatePhoneNumberMutation: GraphQLMutation {
    public static let operationName: String = "MemberUpdatePhoneNumber"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation MemberUpdatePhoneNumber($input: MemberUpdatePhoneNumberInput!) { memberUpdatePhoneNumber(input: $input) { __typename userError { __typename message } } }"#
      ))

    public var input: MemberUpdatePhoneNumberInput

    public init(input: MemberUpdatePhoneNumberInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("memberUpdatePhoneNumber", MemberUpdatePhoneNumber.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberUpdatePhoneNumberMutation.Data.self
      ] }

      public var memberUpdatePhoneNumber: MemberUpdatePhoneNumber { __data["memberUpdatePhoneNumber"] }

      /// MemberUpdatePhoneNumber
      ///
      /// Parent Type: `MemberMutationOutput`
      nonisolated public struct MemberUpdatePhoneNumber: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberMutationOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("userError", UserError?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberUpdatePhoneNumberMutation.Data.MemberUpdatePhoneNumber.self
        ] }

        public var userError: UserError? { __data["userError"] }

        /// MemberUpdatePhoneNumber.UserError
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
            MemberUpdatePhoneNumberMutation.Data.MemberUpdatePhoneNumber.UserError.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}