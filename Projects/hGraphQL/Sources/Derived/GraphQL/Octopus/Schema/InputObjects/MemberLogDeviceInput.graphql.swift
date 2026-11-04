// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  ///  All fields should be non-empty 
  nonisolated struct MemberLogDeviceInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      os: String,
      brand: String,
      model: String,
      pushNotificationEnabled: GraphQLNullable<Bool> = nil
    ) {
      __data = InputDict([
        "os": os,
        "brand": brand,
        "model": model,
        "pushNotificationEnabled": pushNotificationEnabled
      ])
    }

    public var os: String {
      get { __data["os"] }
      set { __data["os"] = newValue }
    }

    public var brand: String {
      get { __data["brand"] }
      set { __data["brand"] = newValue }
    }

    public var model: String {
      get { __data["model"] }
      set { __data["model"] = newValue }
    }

    public var pushNotificationEnabled: GraphQLNullable<Bool> {
      get { __data["pushNotificationEnabled"] }
      set { __data["pushNotificationEnabled"] = newValue }
    }
  }

}