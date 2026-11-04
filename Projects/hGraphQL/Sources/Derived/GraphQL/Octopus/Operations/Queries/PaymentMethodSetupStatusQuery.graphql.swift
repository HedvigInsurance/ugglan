// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PaymentMethodSetupStatusQuery: GraphQLQuery {
    public static let operationName: String = "PaymentMethodSetupStatus"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query PaymentMethodSetupStatus($orderId: ID!) { paymentMethodSetupStatus(orderId: $orderId) { __typename status error { __typename message } } }"#
      ))

    public var orderId: ID

    public init(orderId: ID) {
      self.orderId = orderId
    }

    @_spi(Unsafe) public var __variables: Variables? { ["orderId": orderId] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("paymentMethodSetupStatus", PaymentMethodSetupStatus?.self, arguments: ["orderId": .variable("orderId")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PaymentMethodSetupStatusQuery.Data.self
      ] }

      ///  Returns the status of a setup method order. Returns null if no status found 
      public var paymentMethodSetupStatus: PaymentMethodSetupStatus? { __data["paymentMethodSetupStatus"] }

      /// PaymentMethodSetupStatus
      ///
      /// Parent Type: `PaymentMethodSetupStatusOutput`
      nonisolated public struct PaymentMethodSetupStatus: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PaymentMethodSetupStatusOutput }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("status", GraphQLEnum<OctopusGraphQL.PaymentMethodSetupStatus>.self),
          .field("error", Error_SelectionSet?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PaymentMethodSetupStatusQuery.Data.PaymentMethodSetupStatus.self
        ] }

        ///  The status of the setup process. If FAILED the reason for failure can be found in the `error` field. 
        public var status: GraphQLEnum<OctopusGraphQL.PaymentMethodSetupStatus> { __data["status"] }
        ///  An error message. Only sat if the setup process failed. 
        public var error: Error_SelectionSet? { __data["error"] }

        /// PaymentMethodSetupStatus.Error_SelectionSet
        ///
        /// Parent Type: `UserError`
        nonisolated public struct Error_SelectionSet: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UserError }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("message", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            PaymentMethodSetupStatusQuery.Data.PaymentMethodSetupStatus.Error_SelectionSet.self
          ] }

          public var message: String { __data["message"] }
        }
      }
    }
  }

}