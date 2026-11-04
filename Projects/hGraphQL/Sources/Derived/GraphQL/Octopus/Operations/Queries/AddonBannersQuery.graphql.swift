// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct AddonBannersQuery: GraphQLQuery {
    public static let operationName: String = "AddonBanners"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query AddonBanners($flows: [AddonFlow!]!) { currentMember { __typename addonBanners(flows: $flows) { __typename contractIds displayTitleName descriptionDisplayName badges flow } } }"#
      ))

    public var flows: [GraphQLEnum<AddonFlow>]

    public init(flows: [GraphQLEnum<AddonFlow>]) {
      self.flows = flows
    }

    @_spi(Unsafe) public var __variables: Variables? { ["flows": flows] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("currentMember", CurrentMember.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AddonBannersQuery.Data.self
      ] }

      /// Gets the currently authenticated member. This is the only valid way to query a `Member` type, and it is based
      /// on the input Authorization header.
      public var currentMember: CurrentMember { __data["currentMember"] }

      /// CurrentMember
      ///
      /// Parent Type: `Member`
      nonisolated public struct CurrentMember: OctopusGraphQL.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Member }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("addonBanners", [AddonBanner].self, arguments: ["flows": .variable("flows")]),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AddonBannersQuery.Data.CurrentMember.self
        ] }

        /// Call this to get the info to show banner.
        /// If empty list is returned then member is not eligible for the addon.
        public var addonBanners: [AddonBanner] { __data["addonBanners"] }

        /// CurrentMember.AddonBanner
        ///
        /// Parent Type: `AddonBanner`
        nonisolated public struct AddonBanner: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.AddonBanner }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("contractIds", [OctopusGraphQL.ID].self),
            .field("displayTitleName", String.self),
            .field("descriptionDisplayName", String.self),
            .field("badges", [String].self),
            .field("flow", GraphQLEnum<OctopusGraphQL.AddonFlow>.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            AddonBannersQuery.Data.CurrentMember.AddonBanner.self
          ] }

          /// List of member contracts that is eligible.
          /// One of these ids are required later when calling AddonOffer to get addon prices.
          public var contractIds: [OctopusGraphQL.ID] { __data["contractIds"] }
          /// Title to show in banner page.
          public var displayTitleName: String { __data["displayTitleName"] }
          /// Description to show in banner page.
          public var descriptionDisplayName: String { __data["descriptionDisplayName"] }
          /// Texts to show as badges in banner page. Empty if no banner to show.
          public var badges: [String] { __data["badges"] }
          /// Flow type
          public var flow: GraphQLEnum<OctopusGraphQL.AddonFlow> { __data["flow"] }
        }
      }
    }
  }

}