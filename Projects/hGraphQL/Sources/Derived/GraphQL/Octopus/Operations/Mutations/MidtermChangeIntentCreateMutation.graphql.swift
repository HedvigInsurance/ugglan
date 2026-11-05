// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MidtermChangeIntentCreateMutation: GraphQLMutation {
    public static let operationName: String = "MidtermChangeIntentCreate"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation MidtermChangeIntentCreate($contractId: ID!, $input: MidtermChangeIntentCreateInput!) { midtermChangeIntentCreate(contractId: $contractId, input: $input) { __typename intent { __typename ...MidtermChangeIntentFragment } userError { __typename message } } }"#,
        fragments: [MidtermChangeIntentFragment.self, MidtermChangePriceDetailItemFragment.self, MoneyFragment.self, TotalCostFragment.self]
      ))

    public var contractId: ID
    public var input: MidtermChangeIntentCreateInput

    public init(
      contractId: ID,
      input: MidtermChangeIntentCreateInput
    ) {
      self.contractId = contractId
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { [
      "contractId": contractId,
      "input": input
    ] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("midtermChangeIntentCreate", MidtermChangeIntentCreate.self, arguments: [
          "contractId": .variable("contractId"),
          "input": .variable("input")
        ]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MidtermChangeIntentCreateMutation.Data.self
      ] }

      /// Called to change the co-insured for a contract, returns a generic output containing an intent for the change.
      /// The id of the intent is used in the midtermChangeIntentCommit mutation to realize the new co-insured.
      public var midtermChangeIntentCreate: MidtermChangeIntentCreate { __data["midtermChangeIntentCreate"] }

      /// MidtermChangeIntentCreate
      ///
      /// Parent Type: `MidtermChangeIntentMutationOutput`
      nonisolated public struct MidtermChangeIntentCreate: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MidtermChangeIntentMutationOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("intent", Intent?.self),
          .field("userError", UserError?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MidtermChangeIntentCreateMutation.Data.MidtermChangeIntentCreate.self
        ] }

        public var intent: Intent? { __data["intent"] }
        public var userError: UserError? { __data["userError"] }

        /// MidtermChangeIntentCreate.Intent
        ///
        /// Parent Type: `MidtermChangeIntent`
        nonisolated public struct Intent: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.MidtermChangeIntent }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .fragment(MidtermChangeIntentFragment.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            MidtermChangeIntentCreateMutation.Data.MidtermChangeIntentCreate.Intent.self,
            MidtermChangeIntentFragment.self
          ] }

          public var id: OctopusGraphQL.ID { __data["id"] }
          /// Breakdown of current total cost. Includes addons
          public var currentTotalCost: CurrentTotalCost { __data["currentTotalCost"] }
          /// Breakdown of new total cost. Includes addons
          public var newTotalCost: NewTotalCost { __data["newTotalCost"] }
          /// The date changes will take effect.
          public var activationDate: OctopusGraphQL.Date { __data["activationDate"] }
          /// Includes the quote price breakdown:
          /// insurance base premium, addons premiums, campaigns and bundle discounts
          public var newCostBreakdown: [NewCostBreakdown] { __data["newCostBreakdown"] }

          public struct Fragments: FragmentContainer {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            public var midtermChangeIntentFragment: MidtermChangeIntentFragment { _toFragment() }
          }

          public typealias CurrentTotalCost = MidtermChangeIntentFragment.CurrentTotalCost

          public typealias NewTotalCost = MidtermChangeIntentFragment.NewTotalCost

          public typealias NewCostBreakdown = MidtermChangeIntentFragment.NewCostBreakdown
        }

        /// MidtermChangeIntentCreate.UserError
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
            MidtermChangeIntentCreateMutation.Data.MidtermChangeIntentCreate.UserError.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}