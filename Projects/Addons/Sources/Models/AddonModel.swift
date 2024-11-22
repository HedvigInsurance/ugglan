import Foundation

public struct AddonModel: Identifiable, Equatable {
    public var id = UUID()
    let title: String
    let subTitle: String?
    let tag: String
    let coverageDays: [Int]?
}
