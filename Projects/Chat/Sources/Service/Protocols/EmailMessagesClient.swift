import Foundation
import hCore
import hCoreUI

@MainActor
public protocol EmailMessagesClient {
    func getEmailMessages() async throws -> [EmailMessage]
}

public struct EmailMessage: Identifiable {
    public let id: String
    let recipient: String?
    let subject: String?
    let body: String?
    let deliveryType: String?
    let createdAt: Date?
    let category: String?

    public init(
        id: String,
        recipient: String?,
        subject: String?,
        body: String?,
        deliveryType: String?,
        createdAt: Date?,
        category: String?
    ) {
        self.id = id
        self.recipient = recipient
        self.subject = subject
        self.body = body
        self.deliveryType = deliveryType
        self.createdAt = createdAt
        self.category = category
    }
}
