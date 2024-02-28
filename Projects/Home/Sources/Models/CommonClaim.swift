import Foundation
import hGraphQL

public struct CommonClaim: Codable, Equatable, Hashable {
    public let id: String
    public let icon: IconEnvelope?
    public let imageName: String?
    public let displayTitle: String
    public let layout: Layout

    public enum CommonClaimItemType: String {
        case phone = "PHONE"
    }

    public init(
        id: String,
        icon: IconEnvelope?,
        imageName: String?,
        displayTitle: String,
        layout: Layout
    ) {
        self.id = id
        self.icon = icon
        self.imageName = imageName
        self.displayTitle = displayTitle
        self.layout = layout

    }

    public init(
        claim: OctopusGraphQL.CommonClaimsQuery.Data.CurrentMember.ActiveContract.CurrentAgreement.ProductVariant
            .CommonClaimDescription
    ) {
        self.id = claim.id
        self.displayTitle = claim.title
        self.icon = IconEnvelope(fragment: claim.icon.fragments.iconFragment)
        self.imageName = nil
        self.layout = Layout(layout: claim.layout)
    }

    public struct Layout: Codable, Equatable, Hashable {
        public var titleAndBulletPoint: TitleAndBulletPoints?
        public var emergency: Emergency?

        public init(
            titleAndBulletPoint: TitleAndBulletPoints?,
            emergency: Emergency?
        ) {
            self.titleAndBulletPoint = titleAndBulletPoint
            self.emergency = emergency
        }

        public init(
            layout: OctopusGraphQL.CommonClaimsQuery.Data.CurrentMember.ActiveContract.CurrentAgreement.ProductVariant
                .CommonClaimDescription.Layout
        ) {
            if let emergency = layout.asCommonClaimLayoutEmergency {
                self.emergency = Emergency(
                    title: emergency.title,
                    color: emergency.color.rawValue,
                    emergencyNumber: emergency.emergencyNumber
                )
            } else if let content = layout.asCommonClaimLayoutTitleAndBulletPoints {
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

        public struct TitleAndBulletPoints: Codable, Equatable, Hashable {
            public let color: String
            public var buttonTitle: String?
            public var title: String?
            public var bulletPoints: [BulletPoint]

            public init(
                color: String,
                buttonTitle: String? = nil,
                title: String? = nil,
                bulletPoints: [BulletPoint]
            ) {
                self.color = color
                self.buttonTitle = buttonTitle
                self.title = title
                self.bulletPoints = bulletPoints
            }

            public struct BulletPoint: Codable, Hashable, Equatable {
                public let title: String
                public let description: String
                public let icon: IconEnvelope?

                public init(
                    title: String,
                    description: String,
                    icon: IconEnvelope?
                ) {
                    self.title = title
                    self.description = description
                    self.icon = icon
                }
            }
        }

        public struct Emergency: Codable, Hashable, Equatable {
            public let title: String
            public let color: String
            public let emergencyNumber: String?

            public init(
                title: String,
                color: String,
                emergencyNumber: String? = nil
            ) {
                self.title = title
                self.color = color
                self.emergencyNumber = emergencyNumber
            }

            public var isAlert: Bool {
                return OctopusGraphQL.HedvigColor(rawValue: color) == .yellow
            }
        }
    }
}