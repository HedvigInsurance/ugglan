import Foundation

public struct AddonModel: Identifiable, Equatable, Hashable {
    public var id = UUID()
    let title: String
    let subTitle: String?
    let tag: String
    let coverageDays: [CoverageDays]?
}

public struct CoverageDays: Equatable, Hashable {
    let nbOfDays: Int
    let title: String
    let price: Int
}
