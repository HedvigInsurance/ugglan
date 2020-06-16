//
//  ForeverInvitation.State+RuntimeEnum.swift
//  ForeverExample
//
//  Created by sam on 15.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Forever
import Foundation
import ExampleUtil

extension ForeverInvitation.State: RuntimeEnum {
    public static func fromName(_ name: String) -> ForeverInvitation.State {
        switch name {
        case "active":
            return .active
        case "terminated":
            return .terminated
        case "pending":
            return .pending
        default:
            fatalError("Unhandled case in ForeverInvitation.State")
        }
    }
}
