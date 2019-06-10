//
//  TextStyle.swift
//  project
//
//  Created by Sam Pettersson on 2019-06-04.
//

import Foundation
import Form

extension TextStyle {
    func lineHeight(_ lineHeight: CGFloat) -> TextStyle {
        return restyled { (style: inout TextStyle) in
            style.lineHeight = lineHeight
        }
    }
}
