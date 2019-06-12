//
//  TextStyle.swift
//  project
//
//  Created by Sam Pettersson on 2019-06-04.
//

import Form
import Foundation

extension TextStyle {
    func lineHeight(_ lineHeight: CGFloat) -> TextStyle {
        return restyled { (style: inout TextStyle) in
            style.lineHeight = lineHeight
        }
    }
}
