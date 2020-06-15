//
//  InvitationState+Runtime.swift
//  ForeverExample
//
//  Created by sam on 15.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Forever
import Foundation
import Runtime

extension ForeverInvitation.State: DefaultConstructor {
    public init() {
        self = .active
    }
}
