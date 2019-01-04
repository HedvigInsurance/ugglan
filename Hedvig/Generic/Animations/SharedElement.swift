//
//  SharedElement.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-14.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

struct SharedElementIdentity<T: UIView> {
    typealias View = T
    var identifier: String
}

struct SharedElementIdentities {}

struct SharedElement {
    private static var elements: [String: UIView] = [:]

    static func register<T: UIView>(for identity: SharedElementIdentity<T>, view: T) -> Disposable {
        elements[identity.identifier] = view

        return Disposer {
            guard let index = elements.index(forKey: identity.identifier) else { return }
            elements.remove(at: index)
        }
    }

    static func retreive<T: UIView>(for identity: SharedElementIdentity<T>) -> T? {
        return elements[identity.identifier] as? T
    }
}
