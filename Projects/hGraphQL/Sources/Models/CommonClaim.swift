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
        let medicalPoint = CommonClaim.Layout.TitleAndBulletPoints.BulletPoint(title: "Medical expenses", description: "You will be compensated for necessary and reasonable expenses incurred during the trip (i.e. not after return to your home country) associated with urgent medical care, hospital care, treatment, aids and local travel for care and treatment, if prescribed by a competent doctor.", icon: nil)
        let additionalExpnensePoint = CommonClaim.Layout.TitleAndBulletPoints.BulletPoint(title: "Additional expenses associated with return journey or continued travel", description: "If a doctor recommends, in writing, that you or your travel companion should return home at a different time or by other means than planned, or that you should not continue a pre-booked and paid-for trip, you will be compensated for necessary and reasonable additional expenses associated with your return journey or with re-joining the continued trip at a later date.", icon: nil)
        let costOfRepatriatingPoint = CommonClaim.Layout.TitleAndBulletPoints.BulletPoint(title: "Cost of repatriating deceased individuals and funeral costs", description: "In event of death, the insurance will cover the cost of repatriation of the deceased to the deceased’s home locality in Sweden and additional expenses associated with the return travel of travel companions covered by this insurance policy. When a death occurs abroad, compensation may be granted for burial or cremation locally instead of repatriation, up to a cost of SEK 10,000.", icon: nil)
        let travelExpensensPoint = CommonClaim.Layout.TitleAndBulletPoints.BulletPoint(title: "Travel expenses for relatives visiting seriously ill travellers", description: "If a doctor deems that your injury or illness is life-threatening, we will cover necessary and reasonable expenses associated with no more than two relatives travelling from and back to their home locality in Sweden, including additional accommodation expenses.", icon: nil)
        let additionalAccommodationExpensesPoint = CommonClaim.Layout.TitleAndBulletPoints.BulletPoint(title: "Additional accommodation expenses", description: "If a doctor recommends, in writing, that you or your travel companion should change the planned accommodation arrangements or stay away for longer than planned, we will cover additional expenses for accommodation for up to 45 days from the first doctor’s appointment.", icon: nil)
        let somethingSeriousPoint = CommonClaim.Layout.TitleAndBulletPoints.BulletPoint(title: "When something serious has happened at home", description: "If you are forced to cut a trip short you will be compensated for necessary and reasonable additional expenses associated with your return to your home locality. The trip must be authorised by Hedvig ahead of time. Compensation is awarded only if the return journey is necessary. The insurance does not cover the cost of return to the location where the trip was cut short.", icon: nil)
        let unusedTravelExpensesPoint = CommonClaim.Layout.TitleAndBulletPoints.BulletPoint(title: "Unused travel expenses", description: "You are covered by the insurance for the first 45 days of your trip, provided that the destination is outside of Sweden or that the trip is intended to last longer than 48 hours. The trip is considered to have started once you leave the insured property and to last until you return to that address.", icon: nil)
        let titleAndBulletPoint = CommonClaim.Layout.TitleAndBulletPoints(color: "Red",
                                                                          buttonTitle: "Get travel certificate",
                                                                          title: "TITLE 2",
                                                                          bulletPoints: [medicalPoint, additionalExpnensePoint, costOfRepatriatingPoint, travelExpensensPoint, additionalAccommodationExpensesPoint, somethingSeriousPoint, unusedTravelExpensesPoint])
        let emergency = CommonClaim.Layout.Emergency(title: "Our travel protection is eligible during the first 45 days of your travel and will reimburse you for costs due to acute illness, injury and acute dental injury. If considered necessary, we can provide you with a flight back home to Sweden for further medical. In the event of war or a natural catastrophe during your outbound travel, we will reimburse you for the cost of a flight home and other necessary and reasonable costs.", color: "Red")
        let layout = CommonClaim.Layout(titleAndBulletPoint: titleAndBulletPoint, emergency: emergency)
        let commonClaim = CommonClaim(id: "travelInsurance", icon: nil, iconColor: "#febf03", displayTitle: "Travel Insurance", layout: layout)
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
