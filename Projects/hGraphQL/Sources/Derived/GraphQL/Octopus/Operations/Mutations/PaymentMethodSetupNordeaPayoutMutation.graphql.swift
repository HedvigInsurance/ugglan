// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PaymentMethodSetupNordeaPayoutMutation: GraphQLMutation {
    public static let operationName: String = "PaymentMethodSetupNordeaPayout"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation PaymentMethodSetupNordeaPayout($input: PaymentMethodSetupNordeaPayoutInput!) { paymentMethodSetupNordeaPayout(input: $input) { __typename ...PaymentMethodSetupOutputFragment } }"#,
        fragments: [PaymentMethodSetupOutputFragment.self]
      ))

    public var input: PaymentMethodSetupNordeaPayoutInput

    public init(input: PaymentMethodSetupNordeaPayoutInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("paymentMethodSetupNordeaPayout", PaymentMethodSetupNordeaPayout.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PaymentMethodSetupNordeaPayoutMutation.Data.self
      ] }

      ///  Setup direct bank payout method for the member. 
      public var paymentMethodSetupNordeaPayout: PaymentMethodSetupNordeaPayout { __data["paymentMethodSetupNordeaPayout"] }

      /// PaymentMethodSetupNordeaPayout
      ///
      /// Parent Type: `PaymentMethodSetupOutput`
      nonisolated public struct PaymentMethodSetupNordeaPayout: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PaymentMethodSetupOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(PaymentMethodSetupOutputFragment.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PaymentMethodSetupNordeaPayoutMutation.Data.PaymentMethodSetupNordeaPayout.self,
          PaymentMethodSetupOutputFragment.self
        ] }

        ///  The status of the setup process. If FAILED the reason for failure can be found in the `error` field. 
        public var status: GraphQLEnum<OctopusGraphQL.PaymentMethodSetupStatus> { __data["status"] }
        ///  The order id for the payment method setup order if SUCCESSFUL. 
        public var orderId: OctopusGraphQL.ID? { __data["orderId"] }
        ///  Url to redirect the member to if any. 
        public var url: String? { __data["url"] }
        ///  An error message. Only sat if the setup process failed. 
        public var error: Error_SelectionSet? { __data["error"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var paymentMethodSetupOutputFragment: PaymentMethodSetupOutputFragment { _toFragment() }
        }

        public typealias Error_SelectionSet = PaymentMethodSetupOutputFragment.Error_SelectionSet
      }
    }
  }

}