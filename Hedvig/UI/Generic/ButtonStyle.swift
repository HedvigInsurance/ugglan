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

    static let standardWhite = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: HedvigColors.white,
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 20,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.black
                )
            )
        ]
    }

    static let standardWhiteHighlighted = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: HedvigColors.white.darkened(amount: 0.1),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 20,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.black
                )
            )
        ]
    }

    static let standardTransparentBlack = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: HedvigColors.black.withAlphaComponent(0.3),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 20,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.white
                )
            )
        ]
    }

    static let standardTransparentBlackHighlighted = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: HedvigColors.black.withAlphaComponent(0.6),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 20,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.white
                )
            )
        ]
    }
}
