// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberUpdateLanguageMutation: GraphQLMutation {
    public static let operationName: String = "MemberUpdateLanguage"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation MemberUpdateLanguage($input: MemberUpdateLanguageInput!) { memberUpdateLanguage(input: $input) { __typename userError { __typename message } } }"#
      ))

    public var input: MemberUpdateLanguageInput

    public init(input: MemberUpdateLanguageInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("memberUpdateLanguage", MemberUpdateLanguage.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberUpdateLanguageMutation.Data.self
      ] }

      public var memberUpdateLanguage: MemberUpdateLanguage { __data["memberUpdateLanguage"] }

      /// MemberUpdateLanguage
      ///
      /// Parent Type: `MemberMutationOutput`
      nonisolated public struct MemberUpdateLanguage: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberMutationOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("userError", UserError?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberUpdateLanguageMutation.Data.MemberUpdateLanguage.self
        ] }

        public var userError: UserError? { __data["userError"] }

        /// MemberUpdateLanguage.UserError
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
            MemberUpdateLanguageMutation.Data.MemberUpdateLanguage.UserError.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}