// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct UpsellTravelAddonBannerQuery: GraphQLQuery {
    public static let operationName: String = "UpsellTravelAddonBanner"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query UpsellTravelAddonBanner($flow: UpsellTravelAddonFlow!) { currentMember { __typename upsellTravelAddonBanner(flow: $flow) { __typename contractIds titleDisplayName descriptionDisplayName badges } } }"#
      ))

    public var flow: GraphQLEnum<UpsellTravelAddonFlow>

    public init(flow: GraphQLEnum<UpsellTravelAddonFlow>) {
      self.flow = flow
    }

    @_spi(Unsafe) public var __variables: Variables? { ["flow": flow] }

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("currentMember", CurrentMember.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UpsellTravelAddonBannerQuery.Data.self
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
          .field("upsellTravelAddonBanner", UpsellTravelAddonBanner?.self, arguments: ["flow": .variable("flow")]),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          UpsellTravelAddonBannerQuery.Data.CurrentMember.self
        ] }

        /// Call this to get the info to show in the Travel Addon Upsell or Upgrade banner.
        /// If null is returned then member is not eligable for the travel addon.
        public var upsellTravelAddonBanner: UpsellTravelAddonBanner? { __data["upsellTravelAddonBanner"] }

        /// CurrentMember.UpsellTravelAddonBanner
        ///
        /// Parent Type: `UpsellTravelAddonBanner`
        nonisolated public struct UpsellTravelAddonBanner: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.UpsellTravelAddonBanner }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("contractIds", [OctopusGraphQL.ID].self),
            .field("titleDisplayName", String.self),
            .field("descriptionDisplayName", String.self),
            .field("badges", [String].self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            UpsellTravelAddonBannerQuery.Data.CurrentMember.UpsellTravelAddonBanner.self
          ] }

          /// List of member home contracts that is eligible for travel addon upsell or upgrade depending on source.
          /// One of these ids are required later when calling upsellTravelAddonOffer to get addon prices.
          public var contractIds: [OctopusGraphQL.ID] { __data["contractIds"] }
          /// Title to show in banner page.
          public var titleDisplayName: String { __data["titleDisplayName"] }
          /// Description to show in banner page.
          public var descriptionDisplayName: String { __data["descriptionDisplayName"] }
          /// Texts to show as badges in banner page. Empty if no banner to show.
          public var badges: [String] { __data["badges"] }
        }
      }
    }
  }

}