import Foundation

public struct CommonClaim: Codable, Equatable, Hashable {
    public let id: String
    public let icon: IconEnvelope?
    public let iconColor: String?
    public let displayTitle: String
    public let layout: Layout

    public enum CommonClaimItemType: String {
        case phone = "PHONE"
    }
    
    public init(id: String,
                icon: IconEnvelope?,
                iconColor: String?,
                displayTitle: String,
                layout: Layout){
        self.id = id
        self.icon = icon
        self.iconColor = iconColor
        self.displayTitle = displayTitle
        self.layout = layout
        
    }
    
    public static let travelInsuranceCommonClaim: CommonClaim = {
        let titleAndBulletPoint = CommonClaim.Layout.TitleAndBulletPoints(color: "Red",
                                                                          buttonTitle: "Get travel certificate",
                                                                          title: "TITLE 2",
                                                                          bulletPoints: [])
        let emergency = CommonClaim.Layout.Emergency(title: "Our travel protection is eligible during the first 45 days of your travel and will reimburse you for costs due to acute illness, injury and acute dental injury. If considered necessary, we can provide you with a flight back home to Sweden for further medical. In the event of war or a natural catastrophe during your outbound travel, we will reimburse you for the cost of a flight home and other necessary and reasonable costs.", color: "Red")
        let layout = CommonClaim.Layout(titleAndBulletPoint: titleAndBulletPoint, emergency: emergency)
        let commonClaim = CommonClaim(id: "travelInsurance", icon: nil, iconColor: "#febf03", displayTitle: "Travel Certificate", layout: layout)
        return commonClaim
    }()
    
    
    public init(
        claim: GiraffeGraphQL.CommonClaimsQuery.Data.CommonClaim
    ) {
        self.id = claim.id
        self.displayTitle = claim.title
        self.icon = IconEnvelope(fragment: claim.icon.fragments.iconFragment)
        self.iconColor = nil
        self.layout = Layout(layout: claim.layout)
    }

    public struct Layout: Codable, Equatable, Hashable {
        public var titleAndBulletPoint: TitleAndBulletPoints?
        public var emergency: Emergency?

        
        public init(titleAndBulletPoint: TitleAndBulletPoints?,
                    emergency: Emergency?){
            self.titleAndBulletPoint = titleAndBulletPoint
            self.emergency = emergency
        }
        
        public init(
            layout: GiraffeGraphQL.CommonClaimsQuery.Data.CommonClaim.Layout
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

        public struct TitleAndBulletPoints: Codable, Equatable, Hashable {
            public let color: String
            public var buttonTitle: String?
            public var title: String?
            public var bulletPoints: [BulletPoint]

            public init(color: String, buttonTitle: String? = nil, title: String? = nil, bulletPoints: [BulletPoint]) {
                self.color = color
                self.buttonTitle = buttonTitle
                self.title = title
                self.bulletPoints = bulletPoints
            }
            
            public struct BulletPoint: Codable, Hashable, Equatable {
                public let title: String
                public let description: String
                public let icon: IconEnvelope?
                
                public init(title: String, description: String, icon: IconEnvelope?) {
                    self.title = title
                    self.description = description
                    self.icon = icon
                }
            }
        }

        public struct Emergency: Codable, Hashable, Equatable {
            public let title: String
            public let color: String
            
            public init(title: String, color: String) {
                self.title = title
                self.color = color
            }
        }
    }
}
