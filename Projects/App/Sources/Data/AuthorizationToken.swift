//
//  AuthorizationToken.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-21.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Foundation

struct AuthorizationToken: Codable {
    var token: String

    init(token: String) {
        self.token = token
    }
}
