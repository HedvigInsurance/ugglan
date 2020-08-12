//
//  URL+Helpers.swift
//  project
//
//  Created by Sam Pettersson on 2019-08-20.
//

import Foundation

extension URL {
    public init?(string: String?) {
        guard let string = string, let url = URL(string: string) else {
            return nil
        }

        self = url
    }
}
