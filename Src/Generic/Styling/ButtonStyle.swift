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

extension Button: ButtonTextStylable {
    var textStyle: TextStyle {
        .init(font: .systemFont(ofSize: 20), color: .white)
    }
}

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
                    color: UIColor.white,
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 25,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.black
                )
            ),
        ]
    }

    static let standardWhiteHighlighted = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.white.darkened(amount: 0.1),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 25,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.black
                )
            ),
        ]
    }

    static let standardPurple = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.purple,
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 25,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.white
                )
            ),
        ]
    }

    static let standardPurpleHighlighted = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.purple.darkened(amount: 0.1),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 25,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.white
                )
            ),
        ]
    }

    static let standardBlackPurple = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.blackPurple,
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 25,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(15),
                    color: UIColor.white
                )
            ),
        ]
    }

    static let standardTransparentBlack = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.black.withAlphaComponent(0.3),
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
            ),
        ]
    }

    static let standardTransparentBlackHighlighted = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.black.withAlphaComponent(0.6),
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
            ),
        ]
    }

    static let pillSemiTransparentGray = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.darkGray.withAlphaComponent(0.6),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 15,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(12),
                    color: UIColor.white
                )
            ),
        ]
    }

    static let pillSemiTransparentGrayHighlighted = ButtonStyle.default.restyled { (style: inout ButtonStyle) in
        style.buttonType = .custom
        style.states = [
            .normal: ButtonStateStyle(
                background: BackgroundStyle(
                    color: UIColor.darkGray.withAlphaComponent(0.8),
                    border: BorderStyle(
                        width: 0,
                        color: UIColor.clear,
                        cornerRadius: 15,
                        borderEdges: UIRectEdge()
                    )
                ),
                text: TextStyle(
                    font: HedvigFonts.circularStdBook!.withSize(12),
                    color: UIColor.white
                )
            ),
        ]
    }
}
