import Foundation

public struct CommonClaim: Codable, Equatable {
    public let id: String
    public let icon: IconEnvelope?
    public let displayTitle: String
    public let layout: Layout

    public enum CommonClaimItemType: String {
        case phone = "PHONE"
    }

    public init(
        claim: GraphQL.CommonClaimsQuery.Data.CommonClaim
    ) {
        self.id = claim.id
        self.displayTitle = claim.title
        self.icon = IconEnvelope(fragment: claim.icon.fragments.iconFragment)
        self.layout = Layout(layout: claim.layout)
    }

    public struct Layout: Codable, Equatable {
        public var titleAndBulletPoint: TitleAndBulletPoints?
        public var emergency: Emergency?

        public init(
            layout: GraphQL.CommonClaimsQuery.Data.CommonClaim.Layout
        ) {
            if let emergency = layout.asEmergency {
                self.emergency = Emergency(title: emergency.title, color: emergency.color.rawValue)
            } else if let content = layout.asTitleAndBulletPoints {
                let bulletPoints: [TitleAndBulletPoints.BulletPoint] = content.bulletPoints.map {
                    TitleAndBulletPoints.BulletPoint(
                        title: $0.title,
                        description: $0.description,
                        icon: IconEnvelope(fragment: $0.icon.fragments.iconFragment)
                    )
                }

                self.titleAndBulletPoint = TitleAndBulletPoints(
                    color: content.color.rawValue,
                    buttonTitle: content.buttonTitle,
                    title: content.title,
                    bulletPoints: bulletPoints
                )
            }
        }

        public struct TitleAndBulletPoints: Codable, Equatable {
            public let color: String
            public var buttonTitle: String?
            public var title: String?
            public var bulletPoints: [BulletPoint]

            public struct BulletPoint: Codable, Hashable, Equatable {
                public let title: String
                public let description: String
                public let icon: IconEnvelope?
            }
        }

        public struct Emergency: Codable, Hashable, Equatable {
            public let title: String
            public let color: String
        }
    }
}
