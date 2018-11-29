//
//  ButtonStyle.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-28.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Form
import Foundation

extension ButtonStyle {
    static let invisible = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.clear,
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 0,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: UIFont.systemFont(ofSize: 20),
                    color: UIColor.clear
                )
            )
        ]
    }
}
