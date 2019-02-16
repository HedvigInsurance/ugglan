//
//  Result+Success.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-16.
//

import Foundation
import Flow

extension Flow.Result {
    func isSuccess() -> Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}
