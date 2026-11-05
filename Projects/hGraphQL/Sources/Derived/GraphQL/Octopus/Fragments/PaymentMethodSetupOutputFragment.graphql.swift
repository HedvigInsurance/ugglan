// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct PaymentMethodSetupOutputFragment: OctopusGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString {
      #"fragment PaymentMethodSetupOutputFragment on PaymentMethodSetupOutput { __typename status orderId url error { __typename message } }"#
    }

    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.PaymentMethodSetupOutput }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("status", GraphQLEnum<OctopusGraphQL.PaymentMethodSetupStatus>.self),
      .field("orderId", OctopusGraphQL.ID?.self),
      .field("url", String?.self),
      .field("error", Error_SelectionSet?.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
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

    /// Error_SelectionSet
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
        PaymentMethodSetupOutputFragment.Error_SelectionSet.self
      ] }

      public var message: String { __data["message"] }
    }
  }

}