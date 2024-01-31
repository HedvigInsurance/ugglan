import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

struct TravelInsuranceState: StateProtocol {
    init() {}
    var travelInsuranceList: [TravelCertificateListModel] = []
    @OptionalTransient var travelInsuranceModel: TravelInsuranceModel?
    @OptionalTransient var travelInsuranceConfigs: TravelInsuranceSpecification?
    @OptionalTransient var travelInsuranceConfig: TravelInsuranceContractSpecification?
    @OptionalTransient var downloadURL: URL?
}
