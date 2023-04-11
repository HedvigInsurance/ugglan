import Foundation

enum OdysseyNetworkError: Error {
    case networkError(message: String)
    case badRequest(message: String?)
    case parsingError(message: String)
}

struct ResponseError: Decodable {
    let timestamp: Int
    let status: Int
    let error: String
    let message: String
    let requestId: String
}
