import Foundation
import hGraphQL

public struct FlowClaimInfoStepModel: FlowClaimStepModel {
    let id: String
    let infos: [[FlowClaimInfosModel]]
    
    init(
        with data: OctopusGraphQL.FlowClaimInfoStepFragment
    ) {
        self.id = data.id
        self.infos = []
        
//        self.infos = data.infos.map({ arr in
//            [.init(with: <#T##OctopusGraphQL.FlowClaimInfoStepFragment.Info#>)]
//        })
        
    }
}

public struct FlowClaimInfosModel: Codable, Equatable, Hashable {
    let id: String
//    let value: FlowClaimInfoValueModel?
    
    init(
        with model: OctopusGraphQL.FlowClaimInfoStepFragment.Info
    ) {
        self.id = model.id
//        self.value = model.value
    }
}

public struct FlowClaimInfoValueModel: Codable, Equatable, Hashable {
    let valueAray: [String]?
    let valueString: String?
    let valueBool: Bool?
    let valueDate: String?
    let valueInt: Int?
    
    init(
        with model: OctopusGraphQL.FlowClaimInfoStepFragment.Info.Value? = nil
    ) {
//        if model.asValueArray != nil {
        self.valueAray = model?.asValueArray?.value5
        self.valueString = model?.asValueString?.value1
        self.valueBool = model?.asValueBoolean?.value3
        self.valueDate = model?.asValueDate?.value4
        self.valueInt = model?.asValueInteger?.value2
//        }
//        self.valueAray = model.
//        self.valueString = nil
//        self.valueBool = nil
//        self.valueDate = nil
//        self.valueInt = nil
    }
//    
//    init(
//        with model: OctopusGraphQL.FlowClaimInfoStepFragment.Info.Value.AsValueArray
//    ) {
//        self.valueAray = model.value5
//        self.valueString = nil
//        self.valueBool = nil
//        self.valueDate = nil
//        self.valueInt = nil
//    }
//    
//    init(
//        with model: OctopusGraphQL.FlowClaimInfoStepFragment.Info.Value.AsValueDate
//    ) {
//        self.valueDate = model.value4
//        self.valueString = nil
//        self.valueBool = nil
//        self.valueAray = nil
//        self.valueInt = nil
//    }
//    
//    init(
//        with model: OctopusGraphQL.FlowClaimInfoStepFragment.Info.Value.AsValueString
//    ) {
//        self.valueString = model.value1
//        self.valueDate = nil
//        self.valueBool = nil
//        self.valueAray = nil
//        self.valueInt = nil
//    }
//    
//    init(
//        with model: OctopusGraphQL.FlowClaimInfoStepFragment.Info.Value.AsValueBoolean
//    ) {
//        self.valueBool = model.value3
//        self.valueDate = nil
//        self.valueString = nil
//        self.valueAray = nil
//        self.valueInt = nil
//    }
//    
//    init(
//        with model: OctopusGraphQL.FlowClaimInfoStepFragment.Info.Value.AsValueInteger
//    ) {
//        self.valueInt = model.value2
//        self.valueDate = nil
//        self.valueString = nil
//        self.valueAray = nil
//        self.valueBool = nil
//    }
}

