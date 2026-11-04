// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MemberLogDeviceMutation: GraphQLMutation {
    public static let operationName: String = "MemberLogDevice"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation MemberLogDevice($input: MemberLogDeviceInput!) { memberLogDevice(input: $input) { __typename message } }"#
      ))

    public var input: MemberLogDeviceInput

    public init(input: MemberLogDeviceInput) {
      self.input = input
    }

    @_spi(Unsafe) public var __variables: Variables? { ["input": input] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Mutation }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("memberLogDevice", MemberLogDevice?.self, arguments: ["input": .variable("input")]),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MemberLogDeviceMutation.Data.self
      ] }

      public var memberLogDevice: MemberLogDevice? { __data["memberLogDevice"] }

      /// MemberLogDevice
      ///
      /// Parent Type: `UserError`
      nonisolated public struct MemberLogDevice: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UserError }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("message", String.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MemberLogDeviceMutation.Data.MemberLogDevice.self
        ] }

        public var message: String { __data["message"] }
      }
    }
  }

}