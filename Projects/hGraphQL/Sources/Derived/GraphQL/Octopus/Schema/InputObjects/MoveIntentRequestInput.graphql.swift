// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct MoveIntentRequestInput: InputObject {
    @_spi(Unsafe) public private(set) var __data: InputDict

    @_spi(Unsafe) public init(_ data: InputDict) {
      __data = data
    }

    public init(
      moveToAddress: MoveToAddressInput,
      moveFromAddressId: ID,
      movingDate: Date,
      numberCoInsured: Int32,
      squareMeters: Int32,
      apartment: GraphQLNullable<MoveToApartmentInput> = nil,
      house: GraphQLNullable<MoveToHouseInput> = nil,
      source: GraphQLNullable<GraphQLEnum<MoveIntentSourceInput>> = nil
    ) {
      __data = InputDict([
        "moveToAddress": moveToAddress,
        "moveFromAddressId": moveFromAddressId,
        "movingDate": movingDate,
        "numberCoInsured": numberCoInsured,
        "squareMeters": squareMeters,
        "apartment": apartment,
        "house": house,
        "source": source
      ])
    }

    ///  The new address to move to 
    public var moveToAddress: MoveToAddressInput {
      get { __data["moveToAddress"] }
      set { __data["moveToAddress"] = newValue }
    }

    ///  This is the ID you get in MoveIntent:currentHomeAddresses member selected to move from 
    public var moveFromAddressId: ID {
      get { __data["moveFromAddressId"] }
      set { __data["moveFromAddressId"] = newValue }
    }

    ///  The moving date new insurance should be activated 
    public var movingDate: Date {
      get { __data["movingDate"] }
      set { __data["movingDate"] = newValue }
    }

    ///  The number of co-insured on new address 
    public var numberCoInsured: Int32 {
      get { __data["numberCoInsured"] }
      set { __data["numberCoInsured"] = newValue }
    }

    ///  The number of square meters of new home 
    public var squareMeters: Int32 {
      get { __data["squareMeters"] }
      set { __data["squareMeters"] = newValue }
    }

    ///  Data if to move to an apartment 
    public var apartment: GraphQLNullable<MoveToApartmentInput> {
      get { __data["apartment"] }
      set { __data["apartment"] = newValue }
    }

    ///  Data if to move to house 
    public var house: GraphQLNullable<MoveToHouseInput> {
      get { __data["house"] }
      set { __data["house"] = newValue }
    }

    ///  Where the move was initiated from, defaults to INSURANCE when not sent 
    public var source: GraphQLNullable<GraphQLEnum<MoveIntentSourceInput>> {
      get { __data["source"] }
      set { __data["source"] = newValue }
    }
  }

}