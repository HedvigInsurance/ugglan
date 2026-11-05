// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberDeviceRegisterMutation: GraphQLMutation {
    public static let operationName: String = "MemberDeviceRegister"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation MemberDeviceRegister($token: String!) { memberDeviceRegister(input: { token: $token, platform: IOS }) }"#
      ))

    public var token: String

    public init(token: String) {
      self.token = token
    }

    @_spi(Unsafe) public var __variables: Variables? { ["token": token] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("memberDeviceRegister", Bool.self, arguments: ["input": [
          "token": .variable("token"),
          "platform": "IOS"
        ]]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberDeviceRegisterMutation.Data.self
      ] }

      /// Register a push-notification token to customer.io (which calls it a "Device").
      public var memberDeviceRegister: Bool { __data["memberDeviceRegister"] }
    }
  }

}