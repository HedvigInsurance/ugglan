import Flow
import Foundation

extension Future {
    enum TransformError: Error { case wasNil }

    @discardableResult public func compactMap<O>(
        on scheduler: Scheduler = .current,
        _ transform: @escaping (Value) throws -> O?
    ) -> Future<O> {
        mapResult(on: scheduler) { result in
            switch result {
            case let .success(value):
                if let value = try transform(value) { return value }

                throw TransformError.wasNil
            case let .failure(error): throw error
            }
        }
    }
}
