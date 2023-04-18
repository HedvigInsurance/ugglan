import Foundation

enum OdysseyNetworkError: Error {
    case networkError(message: String)
    case badRequest(message: String?)
    case parsingError(message: String)
}

extension OdysseyNetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return message
        case .badRequest(let message):
            return message
        case .parsingError(let message):
            return message
        }
    }
}
struct ResponseError: Decodable {
    let timestamp: Int
    let status: Int
    let error: String
    let message: String
    let requestId: String
}
