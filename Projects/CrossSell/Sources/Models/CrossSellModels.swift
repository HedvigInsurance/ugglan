import Foundation
import SwiftUI
import hCoreUI

public struct CrossSells: Codable, Equatable, Hashable, Sendable, Identifiable {
    public let id = UUID()
    public let recommended: CrossSell?
    public let others: [CrossSell]

    public init(recommended: CrossSell?, others: [CrossSell]) {
        self.recommended = recommended
        self.others = others
    }
}

public struct CrossSell: Codable, Equatable, Hashable, Sendable, Identifiable {
    public var id: String
    public var title: String
    public var description: String
    public var webActionURL: String?
    public var imageUrl: URL?
    public var hasBeenSeen: Bool {
        didSet {
            UserDefaults.standard.set(hasBeenSeen, forKey: Self.hasBeenSeenKey(typeOfContract: id))
            UserDefaults.standard.synchronize()
        }
    }

    public static func hasBeenSeenKey(typeOfContract: String) -> String {
        "CrossSell-hasBeenSeen-\(typeOfContract)"
    }

    public init(
        id: String,
        title: String,
        description: String,
        webActionURL: String? = nil,
        imageUrl: URL?,
        hasBeenSeen: Bool = false,
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.webActionURL = webActionURL
        self.imageUrl = imageUrl
        self.hasBeenSeen = hasBeenSeen
    }
}
