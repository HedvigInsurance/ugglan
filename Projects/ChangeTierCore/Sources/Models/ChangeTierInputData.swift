import Foundation
import hCore

public struct ChangeTierInputData: Equatable, Identifiable, Codable {
    public var id: String {
        contractId
    }

    public init(
        source: ChangeTierSource,
        contractId: String,
        typeOfContract: TypeOfContract? = nil
    ) {
        self.source = source
        self.contractId = contractId
        self.typeOfContract = typeOfContract
    }

    public let source: ChangeTierSource
    public let contractId: String
    /// Known upfront by the entry points that already hold the contract, so the flow can use the right
    /// wording before the tiers have been fetched. Nil when the caller only knows the contract id.
    public let typeOfContract: TypeOfContract?
}

public struct ChangeTierContractsInput: Equatable, Identifiable {
    public var id: String

    public init(
        source: ChangeTierSource,
        contracts: [ChangeTierContract]
    ) {
        id = "\(Date().timeIntervalSince1970)"
        self.source = source
        self.contracts = contracts
    }

    public let source: ChangeTierSource
    public let contracts: [ChangeTierContract]
}

public struct ChangeTierContract: Hashable {
    public var contractId: String
    public var contractDisplayName: String
    public var contractExposureName: String
    public var typeOfContract: TypeOfContract?

    public init(
        contractId: String,
        contractDisplayName: String,
        contractExposureName: String,
        typeOfContract: TypeOfContract? = nil
    ) {
        self.contractId = contractId
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName
        self.typeOfContract = typeOfContract
    }
}

public enum ChangeTierSource: Codable {
    case changeTier
    case betterPrice
    case betterCoverage
}
