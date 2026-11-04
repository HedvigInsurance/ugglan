// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PaymentMethodSetDefaultPayoutMutation: GraphQLMutation {
    public static let operationName: String = "PaymentMethodSetDefaultPayout"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation PaymentMethodSetDefaultPayout($provider: MemberPaymentProvider!) { paymentMethodSetDefaultPayout(provider: $provider) { __typename message } }"#
      ))

    public var provider: GraphQLEnum<MemberPaymentProvider>

    public init(provider: GraphQLEnum<MemberPaymentProvider>) {
      self.provider = provider
    }

    @_spi(Unsafe) public var __variables: Variables? { ["provider": provider] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("paymentMethodSetDefaultPayout", PaymentMethodSetDefaultPayout?.self, arguments: ["provider": .variable("provider")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PaymentMethodSetDefaultPayoutMutation.Data.self
      ] }

      /// A member can have multiple ACTIVE payment methods where one of those is default. This mutation changes the
      /// members default payment method for payouts to any of his/hers other active payment methods.
      public var paymentMethodSetDefaultPayout: PaymentMethodSetDefaultPayout? { __data["paymentMethodSetDefaultPayout"] }

      /// PaymentMethodSetDefaultPayout
      ///
      /// Parent Type: `UserError`
      nonisolated public struct PaymentMethodSetDefaultPayout: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UserError }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("message", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PaymentMethodSetDefaultPayoutMutation.Data.PaymentMethodSetDefaultPayout.self
        ] }

        public var message: String { __data["message"] }
      }
    }
  }

}