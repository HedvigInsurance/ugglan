// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct UpdateEurobonusNumberMutation: GraphQLMutation {
    public static let operationName: String = "UpdateEurobonusNumber"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdateEurobonusNumber($input: MemberUpdateEurobonusNumberInput!) { memberUpdateEurobonusNumber(input: $input) { __typename userError { __typename message } member { __typename ...PartnerDataFragment } } }"#,
        fragments: [PartnerDataFragment.self]
      ))

    public var input: MemberUpdateEurobonusNumberInput

    public init(input: MemberUpdateEurobonusNumberInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("memberUpdateEurobonusNumber", MemberUpdateEurobonusNumber.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UpdateEurobonusNumberMutation.Data.self
      ] }

      public var memberUpdateEurobonusNumber: MemberUpdateEurobonusNumber { __data["memberUpdateEurobonusNumber"] }

      /// MemberUpdateEurobonusNumber
      ///
      /// Parent Type: `MemberMutationOutput`
      nonisolated public struct MemberUpdateEurobonusNumber: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MemberMutationOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("userError", UserError?.self),
          .field("member", Member?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          UpdateEurobonusNumberMutation.Data.MemberUpdateEurobonusNumber.self
        ] }

        public var userError: UserError? { __data["userError"] }
        public var member: Member? { __data["member"] }

        /// MemberUpdateEurobonusNumber.UserError
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
            UpdateEurobonusNumberMutation.Data.MemberUpdateEurobonusNumber.UserError.self
          ] }

          public var message: String { __data["message"] }
        }

        /// MemberUpdateEurobonusNumber.Member
        ///
        /// Parent Type: `Member`
        nonisolated public struct Member: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Member }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(PartnerDataFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            UpdateEurobonusNumberMutation.Data.MemberUpdateEurobonusNumber.Member.self,
            PartnerDataFragment.self
          ] }

          public var partnerData: PartnerData? { __data["partnerData"] }

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var partnerDataFragment: PartnerDataFragment { _toFragment() }
          }

          public typealias PartnerData = PartnerDataFragment.PartnerData
        }
      }
    }
  }

}