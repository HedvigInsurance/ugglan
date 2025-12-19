import Apollo
import Claims
import Environment
import Foundation
import Kingfisher
import UIKit
import hCore
import hGraphQL

extension NetworkClient: @retroactive hClaimFileUploadClient {
    public func upload(
        endPoint: String,
        files: [File],
        withProgress: (@Sendable (_ progress: Double) -> Void)?
    ) async throws -> [ClaimFileUploadResponse] {
        let request = try await ClaimsRequest.uploadFile(endPoint: endPoint, files: files).asRequest()
        var observation: NSKeyValueObservation?
        let response = try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<[ClaimFileUploadResponse], Error>) in
            let task = self.sessionClient.dataTask(with: request) { [weak self] data, response, error in
                Task {
                    do {
                        if let uploadedFiles: [ClaimFileUploadResponse] = try await self?
                            .handleResponse(data: data, response: response, error: error)
                        {
                            for file in uploadedFiles.compactMap(\.file).enumerated() {
                                let localFileSource = files[file.offset].source
                                switch localFileSource {
                                case let .localFile(results):
                                    if let results = results {
                                        Task { @MainActor in
                                            if MimeType.findBy(mimeType: file.element.mimeType).isImage,
                                                let data = try? await results.itemProvider.getData(),
                                                let image = UIImage(data: data.data)
                                            {
                                                let processor = DownsamplingImageProcessor(
                                                    size: CGSize(width: 300, height: 300)
                                                )
                                                var options = KingfisherParsedOptionsInfo(nil)
                                                options.processor = processor
                                                try? await ImageCache.default.store(
                                                    image,
                                                    forKey: file.element.fileId,
                                                    options: options
                                                )
                                            }
                                        }
                                    }
                                case .url:
                                    break
                                case let .data(data):
                                    if MimeType.findBy(mimeType: file.element.mimeType).isImage,
                                        let image = UIImage(data: data)
                                    {
                                        let processor = DownsamplingImageProcessor(
                                            size: CGSize(width: 300, height: 300)
                                        )
                                        var options = KingfisherParsedOptionsInfo(nil)
                                        options.processor = processor
                                        try? await ImageCache.default.store(
                                            image,
                                            forKey: file.element.fileId,
                                            options: options
                                        )
                                    }
                                }
                            }

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

    public func uploadClaimsChatFile(
        endPoint: String,
        files: [File],
        withProgress: (@Sendable (_ progress: Double) -> Void)?
    ) async throws -> [String] {
        let request = try await ClaimsRequest.uploadFile(endPoint: endPoint, files: files, fromClaimsChat: true)
            .asRequest()
        var observation: NSKeyValueObservation?

        let fileIds = try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<[String], Error>) in
            let task = self.sessionClient.dataTask(with: request) { [weak self] data, response, error in
                Task {
                    do {
                        guard let self else {
                            inCont.resume(throwing: NetworkError.badRequest(message: "NetworkClient deallocated"))
                            return
                        }

                        let responseWrapper: ClaimChatFileUploadResponse? =
                            try await self
                            .handleResponse(data: data, response: response, error: error)

                        let ids = responseWrapper?.fileIds ?? []
                        inCont.resume(returning: ids)
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
        return fileIds
    }
}

@MainActor
private enum ClaimsRequest {
    case uploadFile(endPoint: String, files: [File], fromClaimsChat: Bool? = false)

    private var baseUrl: URL {
        Environment.current.claimsApiURL
    }

    private var claimsChatBaseUrl: URL {
        URL(string: "https://gateway.test.hedvig.com")!
    }

    private var methodType: String {
        switch self {
        case .uploadFile:
            return "POST"
        }
    }

    func asRequest() async throws -> URLRequest {
        var request: URLRequest!
        switch self {
        case let .uploadFile(endPoint, files, fromClaimsChat):
            var baseUrlString = fromClaimsChat ?? false ? claimsChatBaseUrl.absoluteString : baseUrl.absoluteString
            baseUrlString.append(endPoint)
            let url = URL(string: baseUrlString)!
            let multipartFormDataRequest = MultipartFormDataRequest(url: url)
            for file in files {
                var data: Data?
                switch file.source {
                case let .data(fileData):
                    data = fileData
                case .url:
                    break
                case let .localFile(results):
                    if let results {
                        data = try? await results.itemProvider.getData().data
                    }
                }
                guard let data = data else { throw NetworkError.badRequest(message: nil) }
                multipartFormDataRequest.addDataField(
                    fieldName: "files",
                    fileName: file.name,
                    data: data,
                    mimeType: file.mimeType.mime
                )
            }
            request = multipartFormDataRequest.asURLRequest()
        }
        request.httpMethod = methodType
        try await TokenRefresher.shared.refreshIfNeeded()
        let headers = await ApolloClient.headers()
        for element in headers {
            request.setValue(element.value, forHTTPHeaderField: element.key)
        }
        return request
    }
}

public struct ClaimChatFileUploadResponse: Decodable, Sendable {
    public let fileIds: [String]
}
