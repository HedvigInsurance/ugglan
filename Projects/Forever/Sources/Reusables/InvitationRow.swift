//
//  InvitationRow.swift
//  Forever
//
//  Created by sam on 2.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Form
import Flow

struct InvitationRow: Hashable {
    let title: String
}

extension InvitationRow: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (InvitationRow) -> Disposable) {
        let view = UILabel(value: "test", style: .brand(.largeTitle(color: .primary)))
        
        return (view, { `self` in
            
            return NilDisposer()
        })
    }
}
