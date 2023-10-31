import Flow
import Foundation
import hCore

public protocol FileUploaderClient {
    func upload(flowId: String, file: UploadFile) throws -> Future<UploadFileResponseModel>
}

extension NetworkClient: FileUploaderClient {
    public func upload(flowId: String, file: UploadFile) -> Future<UploadFileResponseModel> {
        return Future { [weak self] completion in
            OdysseyRequest.uploadAudioFile(flowId: flowId, file: file).asRequest
                .onValue { request in
                    let task = self?.sessionClient
                        .dataTask(
                            with: request,
                            completionHandler: { (data, response, error) in
                                do {
                                    if let data: UploadFileResponseModel = try self?
                                        .handleResponse(data: data, response: response, error: error)
                                    {
                                        completion(.success(data))
                                    }
                                } catch let error {
                                    completion(.failure(error))
                                }
                            }
                        )
                    task?.resume()
                }
            return NilDisposer()
        }
    }
}
