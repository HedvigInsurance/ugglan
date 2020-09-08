//
//  SubviewOrderable+Spacing.swift
//  hCore
//
//  Created by sam on 21.7.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Form
import Foundation

public enum SpacingType {
    case top
    case inbetween
    case custom(_ height: CGFloat)

    var height: CGFloat {
        switch self {
        case let .custom(height):
            return height
        case .top:
            return 40
        case .inbetween:
            return 16
        }
    }
}

extension SubviewOrderable {
    public func appendSpacing(_ type: SpacingType) {
        let view = UIView()

        view.snp.makeConstraints { make in
            make.height.equalTo(type.height)
        }

        append(view)
    }
}
