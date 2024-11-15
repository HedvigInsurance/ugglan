import Apollo
import Foundation
import Kingfisher
import SwiftUI
import hCore
import hGraphQL

@MainActor
public class hClaimFileUploadService {
    @Inject var client: hClaimFileUploadClient

    public func upload(
        endPoint: String,
        files: [File],
        withProgress: ((_ progress: Double) -> Void)?
    ) async throws -> [ClaimFileUploadResponse] {
        log.info("hClaimFileUploadService: upload", error: nil, attributes: nil)
        return try await client.upload(endPoint: endPoint, files: files, withProgress: withProgress)
    }
}

extension NetworkClient: hClaimFileUploadClient {
    public func upload(
        endPoint: String,
        files: [File],
        withProgress: ((_ progress: Double) -> Void)?
    ) async throws -> [ClaimFileUploadResponse] {
        let request = try await ClaimsRequest.uploadFile(endPoint: endPoint, files: files).asRequest()
        var observation: NSKeyValueObservation?
        let response = try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<[ClaimFileUploadResponse], Error>) -> Void in

            let task = self.sessionClient.dataTask(with: request) { [weak self] (data, response, error) in
                do {
                    if let uploadedFiles: [ClaimFileUploadResponse] = try self?
                        .handleResponse(data: data, response: response, error: error)
                    {
                        for file in uploadedFiles.compactMap({ $0.file }).enumerated() {
                            let localFileSource = files[file.offset].source
                            switch localFileSource {
                            case let .localFile(results):
                                if let results = results {
                                    Task {
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
                            case .url(_):
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
                                    ImageCache.default.store(image, forKey: file.element.fileId, options: options)
                                }
                            }
                        }

                        inCont.resume(returning: uploadedFiles)
                    }
                } catch let error {
                    inCont.resume(throwing: error)
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

public struct ClaimFileUploadResponse: Codable, Sendable {
    let file: FileUpload?
    let error: String?
}

struct FileUpload: Codable, Sendable {
    let fileId: String
    let name: String
    let mimeType: String
    let url: String
}

enum ClaimsRequest {
    case uploadFile(endPoint: String, files: [File])

    var baseUrl: URL {
        return Environment.current.claimsApiURL
    }

    var methodType: String {
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
