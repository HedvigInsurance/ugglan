import Foundation

public struct ChatData {
    let hasNext: Bool
    let id: String
    let messages: [Message]
    let nextUntil: String?
}
