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
    public func upload<T: Codable & Sendable>(url: URL, multipart: MultipartFormDataRequest) async throws -> T {
        let request = try await getRequest(url: url, multipart: multipart)
        let (data, response) = try await sessionClient.data(for: request)
        return try await handleResponseForced(
            data: data,
            response: response,
            error: nil
        )
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
