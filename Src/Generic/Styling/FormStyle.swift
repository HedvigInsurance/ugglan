//
//  FormStyle.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Foundation
import Form

extension FormStyle {
    static let zeroInsets = FormStyle(insets: .zero)
}

extension DynamicFormStyle {
    static let zeroInsets = DynamicFormStyle { (_) -> FormStyle in
        return .zeroInsets
    }
}
