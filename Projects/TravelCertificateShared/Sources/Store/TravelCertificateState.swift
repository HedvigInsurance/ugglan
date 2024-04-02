import Foundation
import Presentation
import hCore

public struct TravelInsuranceState: StateProtocol {
    public init() {}
    var travelInsuranceList: [TravelCertificateModel] = []
    @OptionalTransient var travelInsuranceModel: TravelInsuranceModel?
    @OptionalTransient public var travelInsuranceConfigs: TravelInsuranceSpecification?
    @OptionalTransient var travelInsuranceConfig: TravelInsuranceContractSpecification?
    @OptionalTransient var downloadURL: URL?
}
