//
//  URL+Mock.swift
//  URL+Mock
//
//  Created by Sam Pettersson on 2021-09-10.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation

extension URL {
    /// a mock url to use when mocking
    public static var mock: URL {
        URL(string: "https://www.hedving.com")!
    }
}
