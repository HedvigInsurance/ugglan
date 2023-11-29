import Apollo
import Flow
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hGraphQL

public struct EditCoInsuredState: StateProtocol {

    public init() {}

    //    @Transient(defaultValue: false) public var hasLoadedContractBundlesOnce: Bool
    //    public var activeContracts: [Contract] = []
    //    public var terminatedContracts: [Contract] = []
    //    public var pendingContracts: [Contract] = []
    //    public var crossSells: [CrossSell] = []

    //    public var fetchAllCoInsured: [CoInsuredModel] {
    //        let upcomingCoInsured: [CoInsuredModel] = activeContracts.flatMap { con in
    //            con.upcomingChangedAgreement?.coInsured.filter({ !$0.hasMissingData }) ?? []
    //        }
    //
    //        let coInsured: [CoInsuredModel] = activeContracts.flatMap { con in
    //            con.currentAgreement?.coInsured.filter({ !$0.hasMissingData }) ?? []
    //        }
    //
    //        let unique = Set(upcomingCoInsured + coInsured)
    //        return unique.sorted(by: { $0.fullName ?? "" > $1.fullName ?? "" })
    //    }

    //    public func fetchAllCoInsuredNotInContract(contractId: String) -> [CoInsuredModel] {
    //        let currentCoInsured = contractForId(contractId)?.currentAgreement?.coInsured ?? []
    //        let upcomingCoInsured = contractForId(contractId)?.upcomingChangedAgreement?.coInsured ?? []
    //
    //        let coInsuredNotAdded = fetchAllCoInsured.compactMap {
    //            if !currentCoInsured.contains($0) && !upcomingCoInsured.contains($0) {
    //                return $0
    //            } else {
    //                return nil
    //            }
    //        }
    //
    //        return coInsuredNotAdded
    //    }

    //    public func contractForId(_ id: String) -> Contract? {
    //        let activeContracts = activeContracts.compactMap({ $0 })
    //        let terminatedContracts = terminatedContracts.compactMap({ $0 })
    //        let pendingContracts = pendingContracts.compactMap({ $0 })
    //        let allContracts = activeContracts + terminatedContracts + pendingContracts
    //
    //        if let inBundleContract =
    //            allContracts
    //            .first(where: { contract in
    //                contract.id == id
    //            })
    //        {
    //            return inBundleContract
    //        }
    //
    //        return nil
    //    }
}
