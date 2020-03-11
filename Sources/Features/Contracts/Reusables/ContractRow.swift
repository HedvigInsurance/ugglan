//
//  ContractRow.swift
//  FeatureContracts
//
//  Created by Sam Pettersson on 2020-03-11.
//

import Foundation
import ComponentKit
import Flow
import Form

struct ContractRow: Reusable {
    static func makeAndConfigure() -> (make: UIStackView, configure: (ContractRow) -> Disposable) {
        let stackView = UIStackView()
        
        return (stackView, { `self` in
            return NilDisposer()
        })
    }
}
