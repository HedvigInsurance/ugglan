// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MoveToHouseInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      ancillaryArea: Int32,
      yearOfConstruction: Int32,
      numberOfBathrooms: Int32,
      isSubleted: Bool,
      extraBuildings: [MoveExtraBuildingInput]
    ) {
      __data = InputDict([
        "ancillaryArea": ancillaryArea,
        "yearOfConstruction": yearOfConstruction,
        "numberOfBathrooms": numberOfBathrooms,
        "isSubleted": isSubleted,
        "extraBuildings": extraBuildings
      ])
    }

    ///  The ancillary area of new house 
    public var ancillaryArea: Int32 {
      get { __data["ancillaryArea"] }
      set { __data["ancillaryArea"] = newValue }
    }

    ///  The year of construction of new house 
    public var yearOfConstruction: Int32 {
      get { __data["yearOfConstruction"] }
      set { __data["yearOfConstruction"] = newValue }
    }

    ///  Number of bathrooms in new house 
    public var numberOfBathrooms: Int32 {
      get { __data["numberOfBathrooms"] }
      set { __data["numberOfBathrooms"] = newValue }
    }

    ///  If new house is subleted 
    public var isSubleted: Bool {
      get { __data["isSubleted"] }
      set { __data["isSubleted"] = newValue }
    }

    ///  Extra buildings for new house 
    public var extraBuildings: [MoveExtraBuildingInput] {
      get { __data["extraBuildings"] }
      set { __data["extraBuildings"] = newValue }
    }
  }

}