import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct ClaimsState: StateProtocol {
    var loadingStates: [ClaimsAction: LoadingState<String>] = [:]
    var claims: [Claim]? = nil
    var commonClaims: [CommonClaim]? = nil
    var showTravelInsurance = false
    
    
    public init() {}

    private enum CodingKeys: String, CodingKey {
        case claims, commonClaims
    }
    
    public var getRecommendedForYou: [CommonClaim] {
        var claims = commonClaims ?? []
        if showTravelInsurance {
            claims.append(ClaimsState.travelInsuranceCommonClaim)
        }
        return claims
        
    }

    public var hasActiveClaims: Bool {
        if let claims = claims {
            !claims.filter {
                $0.claimDetailData.status == .beingHandled || $0.claimDetailData.status == .reopened
                    || $0.claimDetailData.status == .submitted
            }
            .isEmpty
        }
        return false
    }
    
    public static let travelInsuranceCommonClaim: CommonClaim = {
        let titleAndBulletPoint = CommonClaim.Layout.TitleAndBulletPoints(color: "",
                                                                          buttonTitle: L10n.TravelCertificate.getTravelCertificateButton,
                                                                          title: "",
                                                                          bulletPoints: [])
        let emergency = CommonClaim.Layout.Emergency(title: L10n.TravelCertificate.description, color: "")
        let layout = CommonClaim.Layout(titleAndBulletPoint: titleAndBulletPoint, emergency: emergency)
        let commonClaim = CommonClaim(id: "travelInsurance", icon: nil, imageName: "travelCertificate", displayTitle: L10n.TravelCertificate.cardTitle, layout: layout)
        return commonClaim
    }()
}

