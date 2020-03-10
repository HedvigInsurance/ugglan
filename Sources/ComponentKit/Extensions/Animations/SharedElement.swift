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

public struct SharedElementIdentity<View: UIView> {
    public var identifier: String
    
    public init(identifier: String) {
        self.identifier = identifier
    }
}

public struct SharedElementIdentities {}

public struct SharedElement {
    private static var elements: [String: UIView] = [:]

    public static func register<T: UIView>(for identity: SharedElementIdentity<T>, view: T) -> Disposable {
        elements[identity.identifier] = view

        return Disposer {
            guard let index = elements.index(forKey: identity.identifier) else { return }
            elements.remove(at: index)
        }
    }

    public static func retreive<T: UIView>(for identity: SharedElementIdentity<T>) -> T? {
        return elements[identity.identifier] as? T
    }
}
