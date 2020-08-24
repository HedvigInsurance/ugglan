//
//  Future+CompactMap.swift
//  hCore
//
//  Created by Sam Pettersson on 2020-08-20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation

extension Future {
    enum TransformError: Error {
        case wasNil
    }

    @discardableResult
    public func compactMap<O>(on scheduler: Scheduler = .current, _ transform: @escaping (Value) throws -> O?) -> Future<O> {
        mapResult(on: scheduler) { result in
            switch result {
            case let .success(value):
                if let value = try transform(value) {
                    return value
                }

                throw TransformError.wasNil
            case let .failure(error): throw error
            }
        }
    }
}
