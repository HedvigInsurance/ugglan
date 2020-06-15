//
//  RuntimeEnum.swift
//  ForeverExample
//
//  Created by sam on 15.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation

protocol RuntimeEnum {
    static func fromName(_ name: String) -> Self
}
