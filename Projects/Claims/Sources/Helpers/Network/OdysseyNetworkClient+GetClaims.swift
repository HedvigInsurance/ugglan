import Flow
import Foundation
import hGraphQL

public protocol GetEntryPointsClaimsClient {
    func execute() throws -> Future<[ClaimEntryPointResponseModel]>
}

extension OdysseyNetworkClient: GetEntryPointsClaimsClient {
    public func execute() throws -> Future<[ClaimEntryPointResponseModel]> {
        return Future { [weak self] completion in
            OdysseyRequest.getCommonClaimsForSelection.asRequest
                .onValue { request in
                    let task = self?.sessionClient
                        .dataTask(
                            with: request,
                            completionHandler: { (data, response, error) in
                                do {
                                    let data: [ClaimEntryPointResponseModel]? = try self?
                                        .handleResponse(data: data, response: response, error: error)
                                    completion(.success(data ?? []))
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
