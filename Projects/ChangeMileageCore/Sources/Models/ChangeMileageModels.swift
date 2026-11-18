import Foundation
import hCore

public struct ChangeMileageIntent: Equatable, Sendable {
    public let activationDate: Date
    /// Monthly cost of the contract on the activation date without the change.
    public let currentTotalCost: Premium
    /// Sorted ascending by mileage, exactly one has `isCurrent` set.
    public let quotes: [MileageQuote]

    public init(activationDate: Date, currentTotalCost: Premium, quotes: [MileageQuote]) {
        self.activationDate = activationDate
        self.currentTotalCost = currentTotalCost
        self.quotes = quotes
    }
}

public struct MileageQuote: Equatable, Hashable, Identifiable, Sendable {
    /// For the current quote this is the id of the agreement being changed, not a quote that can be committed.
    public let id: String
    public let displayName: String
    public let isCurrent: Bool
    public let totalCost: Premium
    public let displayItems: [MileageDisplayItem]

    public init(
        id: String,
        displayName: String,
        isCurrent: Bool,
        totalCost: Premium,
        displayItems: [MileageDisplayItem]
    ) {
        self.id = id
        self.displayName = displayName
        self.isCurrent = isCurrent
        self.totalCost = totalCost
        self.displayItems = displayItems
    }
}

public struct MileageDisplayItem: Equatable, Hashable, Sendable {
    public let title: String
    public let value: String
    /// Set only when the quote changes this row, shown struck through next to `value`.
    public let previousValue: String?

    public init(title: String, value: String, previousValue: String?) {
        self.title = title
        self.value = value
        self.previousValue = previousValue
    }
}

public struct ChangeMileageContract: Equatable, Hashable, Identifiable, Sendable {
    public var id: String { contractId }
    public let contractId: String
    public let displayName: String
    public let exposureName: String
    public let typeOfContract: TypeOfContract?

    public init(contractId: String, displayName: String, exposureName: String, typeOfContract: TypeOfContract?) {
        self.contractId = contractId
        self.displayName = displayName
        self.exposureName = exposureName
        self.typeOfContract = typeOfContract
    }
}

/// Starts the flow for one contract, or lets the member pick among several first.
public struct ChangeMileageInput: Identifiable, Equatable, Sendable {
    public var id: String { contracts.map(\.contractId).joined(separator: ",") }
    public let contracts: [ChangeMileageContract]

    public init(contracts: [ChangeMileageContract]) {
        self.contracts = contracts
    }
}
