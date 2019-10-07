//
//  TextStyle.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-17.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Form
import Foundation

extension TextStyle {
    func centered() -> TextStyle {
        return restyled { (style: inout TextStyle) in
            style.alignment = .center
        }
    }

    static let chatBody = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(15)
        style.color = .primaryText
    }

    static let chatBodyUnderlined = TextStyle.chatBody.restyled { (style: inout TextStyle) in
        style.setAttribute(
            NSUnderlineStyle.single.rawValue,
            for: NSAttributedString.Key.underlineStyle
        )
    }

    static let chatTimeStamp = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(12)
        style.color = .tertiaryText
        style.lineSpacing = 2
    }

    static let body = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.color = .primaryText
        style.lineSpacing = 4
    }

    static let bodyOffBlack = TextStyle.body.restyled { (style: inout TextStyle) in
        style.color = .secondaryText
    }

    static let toastBody = TextStyle.body.restyled { (style: inout TextStyle) in
        style.color = .secondaryText
        style.font = HedvigFonts.circularStdBook!.withSize(15)
    }

    static let bodyWhite = TextStyle.body.restyled { (style: inout TextStyle) in
        style.color = .white
    }

    static let bodyBold = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(14)
        style.color = .primaryText
        style.lineSpacing = 4
    }

    static let navigationSubtitleWhite = TextStyle.body.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(13)
        style.lineSpacing = 4
        style.color = .white
    }

    static let centeredBody = TextStyle.body.restyled { (style: inout TextStyle) in
        style.alignment = .center
    }

    static let centeredBodyOffBlack = TextStyle.bodyOffBlack.restyled { (style: inout TextStyle) in
        style.alignment = .center
    }

    static let sectionHeader = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(15)
        style.color = .darkGray
    }

    static let standaloneLargeTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.soRayExtraBold!.withSize(24)
        style.color = .primaryText
    }

    static let blockRowTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(17)
        style.color = .primaryText
    }

    static let offerBubbleTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(16)
        style.color = .white
        style.alignment = .center
    }

    static let offerBubbleSubtitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.color = .white
        style.alignment = .center
    }

    static let blockRowDescription = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.color = .secondaryText
    }

    static let headingOne = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(40)
        style.color = .primaryText
    }

    static let centeredHeadingOne = TextStyle.headingOne.restyled { (style: inout TextStyle) in
        style.alignment = .center
    }

    static let smallTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.color = .secondaryText
    }

    static let boldSmallTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(16)
        style.color = .primaryText
    }

    static let priceBubbleGrossTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.color = .darkGray
        style.alignment = .center
        style.setAttribute(NSUnderlineStyle.single.rawValue, for: NSAttributedString.Key.strikethroughStyle)
    }

    static let largePriceBubbleTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(60)
        style.color = .primaryText
        style.alignment = .center
    }

    static let reallySmallTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(13)
        style.color = .darkGray
    }

    static let perilTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(12)
        style.color = .decorText
    }

    static let rowTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .primaryText
    }

    static let rowTitleBold = TextStyle.rowTitle.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(17)
    }

    static let rowTitleSecondary = TextStyle.rowTitle.restyled { (style: inout TextStyle) in
        style.color = .secondaryText
    }

    static let rowTitleDisabled = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .gray
    }

    static let rowValueLink = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .primaryTintColor
    }

    static let rowSubtitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.color = .secondaryText
    }

    static let rowSubtitlePrimary = TextStyle.rowSubtitle.restyled { (style: inout TextStyle) in
        style.color = .primaryText
    }

    static let rowValueEditable = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .primaryTintColor
    }

    static let rowValueEditableRight = TextStyle.rowValueEditable.restyled { (style: inout TextStyle) in
        style.alignment = .right
    }

    static let dangerButton = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(15)
        style.color = .pink
    }

    static let normalButton = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(15)
        style.color = .primaryTintColor
    }

    static let navigationBarButton = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .primaryTintColor
    }

    static let navigationBarButtonSkip = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .pink
    }

    static let navigationBarButtonPrimary = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(17)
        style.color = .primaryTintColor
    }

    static let draggableOverlayTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.soRayExtraBold!.withSize(24)
        style.color = .primaryText
    }

    static let countdownNumber = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.soRayExtraBold!.withSize(40)
        style.color = .pink
    }

    static let countdownLetter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(12)
        style.color = .primaryText
    }

    static let offerSummaryTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(23)
        style.color = .violet200
        style.lineHeight = 24
    }
}
