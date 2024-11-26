import Foundation
import SwiftUI

@MainActor
public final class NetworkClient {
    public let sessionClient: URLSession
    public init() {
        let config = URLSessionConfiguration.default
        self.sessionClient = URLSession(configuration: config)
    }

    public func handleResponse<T>(data: Data?, response: URLResponse?, error: Error?) async throws -> T?
    where T: Decodable & Sendable {
        if error != nil {
            throw NetworkError.networkError(message: L10n.General.errorBody)
        }

        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            if let data {
                let responseError = try? JSONDecoder().decode(ResponseError.self, from: data)
                throw NetworkError.badRequest(message: responseError?.message)
            }
            throw NetworkError.badRequest(message: nil)
        }

        guard let responseData = data else {
            return nil
        }

        do {
            let response = try JSONDecoder().decode(T.self, from: responseData)
            return response
        } catch let error {
            throw NetworkError.parsingError(message: error.localizedDescription)
        }
    }
}

public enum NetworkError: Error {
    case networkError(message: String)
    case badRequest(message: String?)
    case parsingError(message: String)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return message
        case .badRequest(let message):
            return message ?? L10n.General.errorBody
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

public struct MultipartFormDataRequest {
    private let boundary: String = UUID().uuidString
    var httpBody = NSMutableData()
    let url: URL

    public init(
        url: URL
    ) {
        self.url = url
    }

    func addTextField(named name: String, value: String) {
        httpBody.appendString(textFormField(named: name, value: value))
    }

    private func textFormField(named name: String, value: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=ISO-8859-1\r\n"
        fieldString += "Content-Transfer-Encoding: 8bit\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        return fieldString
    }

    public func addDataField(fieldName: String, fileName: String, data: Data, mimeType: String) {
        httpBody.append(dataFormField(fieldName: fieldName, fileName: fileName, data: data, mimeType: mimeType))
    }

    private func dataFormField(
        fieldName: String,
        fileName: String,
        data: Data,
        mimeType: String
    ) -> Data {
        let fieldData = NSMutableData()

        fieldData.appendString("--\(boundary)\r\n")
        fieldData.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        fieldData.appendString("Content-Type: \(mimeType)\r\n")
        fieldData.appendString("\r\n")
        fieldData.append(data)
        fieldData.appendString("\r\n")
        return fieldData as Data
    }

    public func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        httpBody.appendString("--\(boundary)--")
        request.httpBody = httpBody as Data
        return request
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
