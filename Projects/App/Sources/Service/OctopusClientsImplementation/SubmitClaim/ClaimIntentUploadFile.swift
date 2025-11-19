import Apollo
import Foundation
//
//  ClaimIntentUploadFile.swift
//  Ugglan
//
//  Created by Sladan Nimcevic on 2025-11-18.
//  Copyright © 2025 Hedvig. All rights reserved.
//
import SubmitClaimChat
import hCore
import hGraphQL

extension NetworkClient: @retroactive hSubmitClaimFileUploadClient {
    public func upload<T>(
        url: URL,
        multipart: hCore.MultipartFormDataRequest,
        withProgress: (@Sendable (Double) -> Void)?
    ) async throws -> T where T: Decodable, T: Encodable, T: Sendable {
        let request = try await getRequest(url: url, multipart: multipart)
        var observation: NSKeyValueObservation?
        let response = try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<T, Error>) in
            let task = self.sessionClient.dataTask(with: request) { [weak self] data, response, error in
                Task {
                    do {
                        if let uploadedFiles: T = try await self?
                            .handleResponseForced(data: data, response: response, error: error)
                        {
                            inCont.resume(returning: uploadedFiles)
                        }
                    } catch {
                        inCont.resume(throwing: error)
                    }
                }
            }
            observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                withProgress?(progress.fractionCompleted)
            }
            task.resume()
        }
        observation?.invalidate()
        return response
    }

    private func getRequest(url: URL, multipart: MultipartFormDataRequest) async throws -> URLRequest {
        var request = multipart.asURLRequest()
        request.httpMethod = "POST"
        try await TokenRefresher.shared.refreshIfNeeded()
        let headers = await ApolloClient.headers()
        for element in headers {
            request.setValue(element.value, forHTTPHeaderField: element.key)
        }
        return request
    }
}
