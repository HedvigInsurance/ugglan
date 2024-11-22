import Foundation

public struct AddonModel: Identifiable {
    public var id = UUID()
    let title: String
    let subTitle: String?
    let tag: String
}
