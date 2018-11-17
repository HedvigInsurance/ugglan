//
//  Persistent.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-16.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation

struct AuthorizationToken: Codable {
    var token: String

    init(token: String) {
        self.token = token
    }
}
