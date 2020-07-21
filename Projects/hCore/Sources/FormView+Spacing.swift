//
//  FormView+Spacing.swift
//  hCore
//
//  Created by sam on 21.7.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Form

extension FormView {
    public enum SpacingType {
        case top
        case inbetween
        
        var height: CGFloat {
            switch self {
            case .top:
                return 40
            case .inbetween:
                return 16
            }
        }
    }
    
    public func appendSpacing(_ type: SpacingType) {
        let view = UIView()
        
        view.snp.makeConstraints { make in
            make.height.equalTo(type.height)
        }
        
        append(view)
    }
}
