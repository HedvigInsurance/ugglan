import Flow
import Foundation
import hGraphQL

public protocol GetEntryPointsClaimsClient {
    func execute() -> Future<[ClaimEntryPointResponseModel]>
}

extension OdysseyNetworkClient: GetEntryPointsClaimsClient {
    public func execute() -> Future<[ClaimEntryPointResponseModel]> {
        return Future { completion in
            let bag = DisposeBag()
            OdysseyRequest.getCommonClaimsForSelection.asRequest
                .onValue { request in
                    let task = self.sessionClient
                        .dataTask(
                            with: request,
                            completionHandler: { (data, response, error) in
                                do {
                                    let data: [ClaimEntryPointResponseModel]? =
                                        try self
                                        .handleResponse(data: data, response: response, error: error)
                                    completion(.success(data ?? []))
                                } catch let error {
                                    completion(.failure(error))
                                }
                            }
                        )
                    bag += Disposer { task.cancel() }
                    task.resume()
                }
            return bag
        }
    }
}
