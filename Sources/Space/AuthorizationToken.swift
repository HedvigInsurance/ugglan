//
//  AuthorizationToken.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-21.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Foundation

public struct AuthorizationToken: Codable {
    public var token: String

    public init(token: String) {
        self.token = token
    }
}
