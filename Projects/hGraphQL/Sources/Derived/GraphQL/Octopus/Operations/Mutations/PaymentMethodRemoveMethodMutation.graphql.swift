// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PaymentMethodRemoveMethodMutation: GraphQLMutation {
    public static let operationName: String = "PaymentMethodRemoveMethod"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation PaymentMethodRemoveMethod($provider: MemberPaymentProvider!) { paymentMethodRemoveMethod(provider: $provider) { __typename message } }"#
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
        .field("paymentMethodRemoveMethod", PaymentMethodRemoveMethod?.self, arguments: ["provider": .variable("provider")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PaymentMethodRemoveMethodMutation.Data.self
      ] }

      ///  Revoke and disconnect an ACTIVE payment method 
      public var paymentMethodRemoveMethod: PaymentMethodRemoveMethod? { __data["paymentMethodRemoveMethod"] }

      /// PaymentMethodRemoveMethod
      ///
      /// Parent Type: `UserError`
      nonisolated public struct PaymentMethodRemoveMethod: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UserError }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("message", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PaymentMethodRemoveMethodMutation.Data.PaymentMethodRemoveMethod.self
        ] }

        public var message: String { __data["message"] }
      }
    }
  }

}