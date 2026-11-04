// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public extension OctopusGraphQL {
  nonisolated struct OngoingShopSessionsQuery: GraphQLQuery {
    public static let operationName: String = "OngoingShopSessions"
    public static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query OngoingShopSessions { currentMember { __typename id ongoingShopSessions { __typename id display { __typename title subtitle monthlyNet { __typename ...MoneyFragment } resumeUrl pillowImage { __typename ...StoryblokImageAssetFragment } } } } }"#,
        fragments: [MoneyFragment.self, StoryblokImageAssetFragment.self]
      ))

    public init() {}

    nonisolated public struct Data: OctopusGraphQL.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Query }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("currentMember", CurrentMember.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        OngoingShopSessionsQuery.Data.self
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
          .field("id", OctopusGraphQL.ID.self),
          .field("ongoingShopSessions", [OngoingShopSession].self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          OngoingShopSessionsQuery.Data.CurrentMember.self
        ] }

        public var id: OctopusGraphQL.ID { __data["id"] }
        /// Shop sessions started by this member that have not yet been signed and are not expired.
        /// Ordered by most recent activity first.
        public var ongoingShopSessions: [OngoingShopSession] { __data["ongoingShopSessions"] }

        /// CurrentMember.OngoingShopSession
        ///
        /// Parent Type: `ShopSession`
        nonisolated public struct OngoingShopSession: OctopusGraphQL.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ShopSession }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", OctopusGraphQL.UUID.self),
            .field("display", Display.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            OngoingShopSessionsQuery.Data.CurrentMember.OngoingShopSession.self
          ] }

          public var id: OctopusGraphQL.UUID { __data["id"] }
          /// Display-ready summary of this session for surfacing it in member-facing lists
          /// (e.g. the Hedvig mobile app's home screen).
          public var display: Display { __data["display"] }

          /// CurrentMember.OngoingShopSession.Display
          ///
          /// Parent Type: `ShopSessionDisplay`
          nonisolated public struct Display: OctopusGraphQL.SelectionSet {
            @_spi(Unsafe) public let __data: DataDict
            @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

            @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.ShopSessionDisplay }
            @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("title", String.self),
              .field("subtitle", String?.self),
              .field("monthlyNet", MonthlyNet?.self),
              .field("resumeUrl", String.self),
              .field("pillowImage", PillowImage?.self),
            ] }
            @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
              OngoingShopSessionsQuery.Data.CurrentMember.OngoingShopSession.Display.self
            ] }

            /// Title summarizing the session's products, e.g. "Car Insurance Full" for a single
            /// product or "Home + Accident" when several products are in play. Uses each product's
            /// full localized display name (tier-specific where applicable).
            public var title: String { __data["title"] }
            /// Optional secondary line with insured-object info, e.g. "Studio apartment, Stockholm".
            /// Null when no insured-object data is available.
            public var subtitle: String? { __data["subtitle"] }
            /// Effective monthly price after any campaign/bundle discounts.
            /// Null when the session has no priced offers in the cart.
            public var monthlyNet: MonthlyNet? { __data["monthlyNet"] }
            /// Absolute URL to open in a browser to resume this session. Clients open it
            /// directly in the device browser, no auth is required.
            public var resumeUrl: String { __data["resumeUrl"] }
            /// Pillow image of the primary product in the session, suitable as a card icon.
            /// Null when no product is yet associated with the session.
            public var pillowImage: PillowImage? { __data["pillowImage"] }

            /// CurrentMember.OngoingShopSession.Display.MonthlyNet
            ///
            /// Parent Type: `Money`
            nonisolated public struct MonthlyNet: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.Money }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(MoneyFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                OngoingShopSessionsQuery.Data.CurrentMember.OngoingShopSession.Display.MonthlyNet.self,
                MoneyFragment.self
              ] }

              public var amount: Double { __data["amount"] }
              /// Currency of the money (ISO 4217).
              public var currencyCode: GraphQLEnum<OctopusGraphQL.CurrencyCode> { __data["currencyCode"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var moneyFragment: MoneyFragment { _toFragment() }
              }
            }

            /// CurrentMember.OngoingShopSession.Display.PillowImage
            ///
            /// Parent Type: `StoryblokImageAsset`
            nonisolated public struct PillowImage: OctopusGraphQL.SelectionSet {
              @_spi(Unsafe) public let __data: DataDict
              @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

              @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { OctopusGraphQL.Objects.StoryblokImageAsset }
              @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .fragment(StoryblokImageAssetFragment.self),
              ] }
              @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
                OngoingShopSessionsQuery.Data.CurrentMember.OngoingShopSession.Display.PillowImage.self,
                StoryblokImageAssetFragment.self
              ] }

              public var src: String { __data["src"] }

              public struct Fragments: FragmentContainer {
                @_spi(Unsafe) public let __data: DataDict
                @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

                public var storyblokImageAssetFragment: StoryblokImageAssetFragment { _toFragment() }
              }
            }
          }
        }
      }
    }
  }

}