import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct TravelInsuranceState: StateProtocol {
    public init() {}
    var travelInsuranceList: [TravelCertificateModel] = []
    @OptionalTransient var travelInsuranceModel: TravelInsuranceModel?
    @OptionalTransient var travelInsuranceConfigs: TravelInsuranceSpecification?
    @OptionalTransient var travelInsuranceConfig: TravelInsuranceContractSpecification?
    @OptionalTransient var downloadURL: URL?
}
