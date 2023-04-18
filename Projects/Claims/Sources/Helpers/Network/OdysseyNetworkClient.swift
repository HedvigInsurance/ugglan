import Foundation
import UIKit
import hCore

public final class OdysseyNetworkClient {
    let sessionClient: URLSession
    public init() {
        let config = URLSessionConfiguration.default
        self.sessionClient = URLSession(configuration: config)
    }

    func handleResponse<T>(data: Data?, response: URLResponse?, error: Error?) throws -> T? where T: Decodable {
        if error != nil {
            throw OdysseyNetworkError.networkError(message: L10n.General.errorBody)
        }

        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            if let data {
                let responseError = try? JSONDecoder().decode(ResponseError.self, from: data)
                throw OdysseyNetworkError.badRequest(message: responseError?.message)
            }
            throw OdysseyNetworkError.badRequest(message: nil)
        }

        guard let responseData = data else {
            return nil
        }

        do {
            let response = try JSONDecoder().decode(T.self, from: responseData)
            return response
        } catch let error {
            throw OdysseyNetworkError.parsingError(message: error.localizedDescription)
        }
    }
}
