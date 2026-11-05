// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MoveToApartmentInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      subType: GraphQLEnum<MoveApartmentSubType>,
      isStudent: Bool
    ) {
      __data = InputDict([
        "subType": subType,
        "isStudent": isStudent
      ])
    }

    ///  The subtype of new apartment 
    public var subType: GraphQLEnum<MoveApartmentSubType> {
      get { __data["subType"] }
      set { __data["subType"] = newValue }
    }

    ///  If member is student 
    public var isStudent: Bool {
      get { __data["isStudent"] }
      set { __data["isStudent"] = newValue }
    }
  }

}