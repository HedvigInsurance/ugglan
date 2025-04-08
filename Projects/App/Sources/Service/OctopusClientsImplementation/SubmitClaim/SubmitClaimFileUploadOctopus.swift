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
            (inCont: CheckedContinuation<[ClaimFileUploadResponse], Error>) -> Void in
            let task = self.sessionClient.dataTask(with: request) { [weak self] (data, response, error) in
                Task {
                    do {
                        if let uploadedFiles: [ClaimFileUploadResponse] = try await self?
                            .handleResponse(data: data, response: response, error: error)
                        {
                            for file in uploadedFiles.compactMap({ $0.file }).enumerated() {
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
                                                var options = KingfisherParsedOptionsInfo.init(nil)
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
                                case .data(let data):
                                    if MimeType.findBy(mimeType: file.element.mimeType).isImage,
                                        let image = UIImage(data: data)
                                    {
                                        let processor = DownsamplingImageProcessor(
                                            size: CGSize(width: 300, height: 300)
                                        )
                                        var options = KingfisherParsedOptionsInfo.init(nil)
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
                    } catch let error {
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
}

@MainActor
private enum ClaimsRequest {
    case uploadFile(endPoint: String, files: [File])

    private var baseUrl: URL {
        return Environment.current.claimsApiURL
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
        case let .uploadFile(endPoint, files):
            var baseUrlString = baseUrl.absoluteString
            baseUrlString.append(endPoint)
            let url = URL(string: baseUrlString)!
            let multipartFormDataRequest = MultipartFormDataRequest(url: url)
            for file in files {
                var data: Data?
                switch file.source {
                case .data(let fileData):
                    data = fileData
                case .url:
                    break
                case .localFile(let results):
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
        request.httpMethod = self.methodType
        try await TokenRefresher.shared.refreshIfNeeded()
        let headers = await ApolloClient.headers()
        headers.forEach { element in
            request.setValue(element.value, forHTTPHeaderField: element.key)
        }
        return request
    }
}
