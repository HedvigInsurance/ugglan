//
//  ButtonStyle.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-28.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Form
import Foundation
import ComponentKit

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
            ),
        ]
    }

    static let standardWhite = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.hedvig(.white),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 25,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.hedvig(.black)
                )
            ),
        ]
    }

    static let standardWhiteHighlighted = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.hedvig(.white).darkened(amount: 0.1),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 25,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.hedvig(.black)
                )
            ),
        ]
    }

    static let standardPurple = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.hedvig(.purple),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 25,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.hedvig(.white)
                )
            ),
        ]
    }

    static let standardPurpleHighlighted = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.hedvig(.purple).darkened(amount: 0.1),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 25,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.hedvig(.white)
                )
            ),
        ]
    }

    static let standardBlackPurple = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.hedvig(.blackPurple),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 25,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.hedvig(.white)
                )
            ),
        ]
    }

    static let standardTransparentBlack = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.hedvig(.black).withAlphaComponent(0.3),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 20,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.hedvig(.white)
                )
            ),
        ]
    }

    static let standardTransparentBlackHighlighted = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.hedvig(.black).withAlphaComponent(0.6),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 20,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.hedvig(.white)
                )
            ),
        ]
    }

    static let pillSemiTransparentGray = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.hedvig(.darkGray).withAlphaComponent(0.6),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 15,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(12),
                    color: UIColor.hedvig(.white)
                )
            ),
        ]
    }

    static let pillSemiTransparentGrayHighlighted = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.hedvig(.darkGray).withAlphaComponent(0.8),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 15,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(12),
                    color: UIColor.hedvig(.white)
                )
            ),
        ]
    }
}
