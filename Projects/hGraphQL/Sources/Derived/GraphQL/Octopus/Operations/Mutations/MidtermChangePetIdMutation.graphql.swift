// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MidtermChangePetIdMutation: GraphQLMutation {
    public static let operationName: String = "MidtermChangePetId"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation MidtermChangePetId($contractId: ID!, $petId: String!) { midtermChangePetId(contractId: $contractId, petId: $petId) { __typename ... on MidtermChangePetIdActivationDate { activationDate } ... on UserError { message } } }"#
      ))

    public var contractId: ID
    public var petId: String

    public init(
      contractId: ID,
      petId: String
    ) {
      self.contractId = contractId
      self.petId = petId
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "contractId": contractId,
      "petId": petId
    ] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("midtermChangePetId", MidtermChangePetId.self, arguments: [
          "contractId": .variable("contractId"),
          "petId": .variable("petId")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MidtermChangePetIdMutation.Data.self
      ] }

      /// Called to change the Pet-Id of a cat/dog contract. Creates a midterm change without price change and commits it.
      public var midtermChangePetId: MidtermChangePetId { __data["midtermChangePetId"] }

      /// MidtermChangePetId
      ///
      /// Parent Type: `MidtermChangePetIdOutput`
      nonisolated public struct MidtermChangePetId: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Unions.MidtermChangePetIdOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .inlineFragment(AsMidtermChangePetIdActivationDate.self),
          .inlineFragment(AsUserError.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MidtermChangePetIdMutation.Data.MidtermChangePetId.self
        ] }

        public var asMidtermChangePetIdActivationDate: AsMidtermChangePetIdActivationDate? { _asInlineFragment() }
        public var asUserError: AsUserError? { _asInlineFragment() }

        /// MidtermChangePetId.AsMidtermChangePetIdActivationDate
        ///
        /// Parent Type: `MidtermChangePetIdActivationDate`
        nonisolated public struct AsMidtermChangePetIdActivationDate: OctopusGraphQL.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = MidtermChangePetIdMutation.Data.MidtermChangePetId
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MidtermChangePetIdActivationDate }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("activationDate", OctopusGraphQL.Date.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MidtermChangePetIdMutation.Data.MidtermChangePetId.self,
            MidtermChangePetIdMutation.Data.MidtermChangePetId.AsMidtermChangePetIdActivationDate.self
          ] }

          /// Activation date of the MTA agreement.
          public var activationDate: OctopusGraphQL.Date { __data["activationDate"] }
        }

        /// MidtermChangePetId.AsUserError
        ///
        /// Parent Type: `UserError`
        nonisolated public struct AsUserError: OctopusGraphQL.InlineFragment {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = MidtermChangePetIdMutation.Data.MidtermChangePetId
          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UserError }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("message", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MidtermChangePetIdMutation.Data.MidtermChangePetId.self,
            MidtermChangePetIdMutation.Data.MidtermChangePetId.AsUserError.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}