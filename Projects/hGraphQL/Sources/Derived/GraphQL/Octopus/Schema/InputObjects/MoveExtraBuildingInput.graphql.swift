// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MoveExtraBuildingInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      area: Int32,
      type: String,
      hasWaterConnected: Bool
    ) {
      __data = InputDict([
        "area": area,
        "type": type,
        "hasWaterConnected": hasWaterConnected
      ])
    }

    ///  Area of extra building 
    public var area: Int32 {
      get { __data["area"] }
      set { __data["area"] = newValue }
    }

    ///  Extra building type 
    public var type: String {
      get { __data["type"] }
      set { __data["type"] = newValue }
    }

    ///  If extra building has water connected 
    public var hasWaterConnected: Bool {
      get { __data["hasWaterConnected"] }
      set { __data["hasWaterConnected"] = newValue }
    }
  }

}