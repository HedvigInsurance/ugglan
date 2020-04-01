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

    var zeroedLineSpacing: TextStyle {
        restyled { (style: inout TextStyle) in
            style.lineSpacing = 0
        }
    }

    static let chatBody = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(15)
        style.color = .primaryText
        style.lineSpacing = 5
    }

    static let chatBodyUnderlined = TextStyle.chatBody.restyled { (style: inout TextStyle) in
        style.setAttribute(
            NSUnderlineStyle.single.rawValue,
            for: NSAttributedString.Key.underlineStyle
        )
    }

    static let chatTimeStamp = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(12)
        style.color = .tertiaryText
        style.lineSpacing = 2
    }

    static let body = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.color = .primaryText
        style.lineSpacing = 6
    }

    static let bodyButtonText = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.color = .primaryText
    }

    static let bodyBookButtonText = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.color = .primaryText
    }

    static let bodyOffBlack = TextStyle.body.restyled { (style: inout TextStyle) in
        style.color = .secondaryText
    }

    static let toastBody = TextStyle.body.restyled { (style: inout TextStyle) in
        style.color = .secondaryText
        style.font = HedvigFonts.favoritStdBook!.withSize(15)
    }

    static let toastBodySubtitle = TextStyle.body.restyled { (style: inout TextStyle) in
        style.color = .secondaryText
        style.font = HedvigFonts.favoritStdBook!.withSize(12)
    }

    static let bodyWhite = TextStyle.body.restyled { (style: inout TextStyle) in
        style.color = .white
    }

    static let bodyBold = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(14)
        style.color = .primaryText
        style.lineSpacing = 6
    }

    static let navigationSubtitle = TextStyle.body.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(13)
        style.lineSpacing = 6
        style.color = .primaryText
    }

    static let centeredBody = TextStyle.body.restyled { (style: inout TextStyle) in
        style.alignment = .center
    }

    static let centeredBodyOffBlack = TextStyle.bodyOffBlack.restyled { (style: inout TextStyle) in
        style.alignment = .center
    }

    static let sectionHeader = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(15)
        style.color = .darkGray
    }

    static let standaloneLargeTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(24)
        style.color = .primaryText
    }

    static let blockRowTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(17)
        style.color = .primaryText
    }

    static let offerBubbleTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(16)
        style.color = .primaryTextNeg
        style.alignment = .center
    }

    static let offerBubbleSubtitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(16)
        style.color = .primaryTextNeg
        style.alignment = .center
    }

    static let blockRowDescription = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.color = .secondaryText
    }

    static let headingOne = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(40)
        style.color = .primaryText
    }

    static let centeredHeadingOne = TextStyle.headingOne.restyled { (style: inout TextStyle) in
        style.alignment = .center
    }

    static let smallTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(16)
        style.color = .secondaryText
    }

    static let boldSmallTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(16)
        style.color = .primaryText
    }

    static let priceBubbleGrossTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.color = .primaryText
        style.alignment = .center
        style.setAttribute(NSUnderlineStyle.single.rawValue, for: NSAttributedString.Key.strikethroughStyle)
    }

    static let largePriceBubbleTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(60)
        style.color = .primaryText
        style.alignment = .center
    }

    static let reallySmallTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(13)
        style.color = .darkGray
    }

    static let perilTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(12)
        style.color = .decorText
    }

    static let rowTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(17)
        style.lineHeight = 15
        style.color = .primaryText
    }

    static let rowTitleBold = TextStyle.rowTitle.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(17)
        style.lineHeight = 15
    }

    static let rowTitleSecondary = TextStyle.rowTitle.restyled { (style: inout TextStyle) in
        style.color = .secondaryText
        style.lineHeight = 15
    }

    static let rowTitleDisabled = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(17)
        style.color = .gray
        style.lineHeight = 15
    }

    static let rowValueLink = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(17)
        style.color = .primaryTintColor
        style.lineHeight = 15
    }

    static let rowSubtitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.lineHeight = 15
        style.color = .secondaryText
    }

    static let rowTertitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(12)
        style.color = .secondaryText
        style.lineHeight = 15
    }

    static let rowSubtitlePrimary = TextStyle.rowSubtitle.restyled { (style: inout TextStyle) in
        style.color = .primaryText
    }

    static let rowValueEditable = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(17)
        style.color = .primaryTintColor
    }

    static let rowValueEditableMuted = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(17)
        style.color = .primaryText
    }

    static let rowValueEditablePlaceholder = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(17)
        style.color = .primaryTextMuted
    }

    static let rowValueEditableRight = TextStyle.rowValueEditable.restyled { (style: inout TextStyle) in
        style.alignment = .right
    }

    static let dangerButton = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(15)
        style.color = .pink
    }

    static let normalButton = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(15)
        style.color = .primaryTintColor
    }

    static let navigationBarButton = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(17)
        style.color = .primaryTintColor
    }

    static let navigationBarButtonSkip = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(17)
        style.color = .pink
    }

    static let navigationBarButtonPrimary = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(17)
        style.color = .primaryTintColor
    }

    static let draggableOverlayTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(24)
        style.color = .primaryText
    }

    static let countdownNumber = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(40)
        style.color = .pink
    }

    static let countdownLetter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(12)
        style.color = .primaryText
    }

    static let offerSummaryTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(23)
        style.color = .violet200
        style.lineHeight = 24
    }

    static let draggableOverlayDescription = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.lineHeight = 20
        style.color = .secondaryText
    }

    static let headerLargeTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(30)
        style.lineHeight = 32
        style.color = .primaryText
    }

    static let headlineLargeLargeRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(24)
        style.lineHeight = 24
        style.alignment = .right
        style.color = .primaryText
    }

    static let headlineLargeLargeLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(24)
        style.lineHeight = 24
        style.color = .primaryText
    }

    static let headlineLargeNegLargeNegLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(24)
        style.lineHeight = 24
        style.color = .primaryTextNeg
    }

    static let headlineLargeLargeCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(24)
        style.lineHeight = 24
        style.color = .primaryText
        style.alignment = .center
    }

    static let headlineLargeNegLargeNegCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(24)
        style.lineHeight = 24
        style.color = .primaryTextNeg
        style.alignment = .center
    }

    static let headlineLargeNegLargeNegRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(24)
        style.lineHeight = 24
        style.color = .primaryTextNeg
        style.alignment = .right
    }

    static let headlineMediumNegMediumNegRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(16)
        style.lineHeight = 24
        style.color = .primaryTextNeg
        style.alignment = .right
    }

    static let headlineMediumNegMediumNegLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(16)
        style.lineHeight = 24
        style.color = .primaryTextNeg
    }

    static let headlineMediumMediumLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(16)
        style.lineHeight = 15
        style.color = .primaryText
    }

    static let headlineMediumMediumRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(16)
        style.lineHeight = 24
        style.color = .primaryText
        style.alignment = .right
    }

    static let headlineMediumNegMediumNegCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(16)
        style.lineHeight = 24
        style.color = .primaryTextNeg
        style.alignment = .center
    }

    static let headlineMediumMediumCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(16)
        style.lineHeight = 24
        style.color = .primaryText
        style.alignment = .center
    }

    static let linksRegularCautionRegularLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(16)
        style.lineHeight = 24
        style.letterSpacing = 0.2
        style.color = .regularCaution
    }

    static let linksRegularRegularRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(16)
        style.lineHeight = 24
        style.letterSpacing = 0.2
        style.color = .linksRegular
    }

    static let headerRegularTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(16)
        style.lineHeight = 18
        style.color = .primaryText
    }

    static let linksRegularRegularLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(16)
        style.lineHeight = 18
        style.color = .linksRegular
    }

    static let bodyRegularRegularLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(16)
        style.lineHeight = 18
        style.color = .regularBody
    }

    static let bodyRegularNegRegularNegCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(16)
        style.lineHeight = 24
        style.letterSpacing = 0.2
        style.color = .regularBody
        style.alignment = .center
    }

    static let linksRegularRegularCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(16)
        style.lineHeight = 24
        style.color = .linksRegular
        style.letterSpacing = 0.2
        style.alignment = .center
    }

    static let bodyRegularRegularCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(16)
        style.alignment = .center
        style.lineHeight = 24
        style.color = .regularBody
        style.letterSpacing = 0.2
    }

    static let bodyRegularNegRegularNegLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(16)
        style.lineHeight = 24
        style.color = .primaryTextNeg
        style.letterSpacing = 0.2
    }

    static let bodyRegularRegularRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(16)
        style.lineHeight = 24
        style.color = .regularBody
        style.letterSpacing = 0.2
        style.alignment = .right
    }

    static let bodyRegularNegRegularNegRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(16)
        style.lineHeight = 24
        style.color = .primaryTextNeg
        style.letterSpacing = 0.2
        style.alignment = .right
    }

    static let linksRegularCautionRegularRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(16)
        style.lineHeight = 24
        style.letterSpacing = 0.2
        style.color = .linksRegular
        style.alignment = .right
    }

    static let linksRegularCautionRegularCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(16)
        style.lineHeight = 24
        style.letterSpacing = 0.2
        style.color = .linksRegular
        style.alignment = .center
    }

    static let headLineSmallSmallCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(14)
        style.lineHeight = 20
        style.color = .primaryText
        style.alignment = .center
    }

    static let headlineSmallNegSmallNegRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(14)
        style.lineHeight = 20
        style.color = .primaryTextNeg
        style.alignment = .right
    }

    static let headlineSmallSmallRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(14)
        style.lineHeight = 20
        style.color = .primaryText
        style.alignment = .right
    }

    static let headlineSmallSmallLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.lineHeight = 15
        style.color = .primaryText
    }

    static let headlineSmallNegSmallNegCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(14)
        style.lineHeight = 15
        style.color = .primaryTextNeg
        style.alignment = .center
    }

    static let headlineSmallNegSmallNegLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBold!.withSize(14)
        style.lineHeight = 15
        style.color = .primaryTextNeg
    }

    static let bodySmallNegSmallNegRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.lineHeight = 15
        style.color = .primaryTextNeg
        style.letterSpacing = 0.2
        style.alignment = .right
    }

    static let linksSmallCautionSmallCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.lineHeight = 15
        style.color = .regularCaution
        style.letterSpacing = 0.2
        style.alignment = .center
    }

    static let bodySmallSmallRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.lineHeight = 15
        style.color = .regularBody
        style.letterSpacing = 0.2
        style.alignment = .right
    }

    static let linksSmallSmallCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.lineHeight = 15
        style.color = .linksRegular
        style.letterSpacing = 0.2
        style.alignment = .center
    }

    static let bodySmallNegSmallNegLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.lineHeight = 15
        style.color = .primaryTextNeg
        style.letterSpacing = 0.2
    }

    static let linksSmallSmallRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.lineHeight = 15
        style.color = .linksRegular
        style.letterSpacing = 0.2
    }

    static let bodySmallSmallCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.lineHeight = 20
        style.color = .regularBody
        style.letterSpacing = 0
        style.alignment = .center
    }

    static let bodySmallSmallLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.lineHeight = 15
        style.color = .regularBody
        style.letterSpacing = 0.2
    }

    static let bodySmallNegSmallNegCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.lineHeight = 15
        style.color = .primaryTextNeg
        style.letterSpacing = 0.2
        style.alignment = .center
    }

    static let linksSmallCautionSmallLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.lineHeight = 15
        style.color = .regularCaution
        style.letterSpacing = 0.2
    }

    static let linksSmallCautionSmallRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.lineHeight = 15
        style.color = .regularCaution
        style.letterSpacing = 0.2
        style.alignment = .right
    }

    static let linksSmallSmallLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(14)
        style.lineHeight = 15
        style.color = .linksRegular
        style.letterSpacing = 0.2
    }

    static let bodyXSmallNegXSmallNegCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(12)
        style.lineHeight = 16
        style.color = .primaryTextNeg
        style.letterSpacing = 0.1
        style.alignment = .center
    }

    static let bodyXSmallXSmallCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(12)
        style.lineHeight = 16
        style.color = .regularBody
        style.letterSpacing = 0.1
        style.alignment = .center
    }

    static let bodyXSmallNegXSmallNegRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(12)
        style.lineHeight = 16
        style.color = .primaryTextNeg
        style.letterSpacing = 0.1
        style.alignment = .right
    }

    static let bodyXSmallXSmallLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(12)
        style.lineHeight = 16
        style.color = .regularBody
        style.letterSpacing = 0.1
    }

    static let bodyXSmallNegXSmallNegLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(12)
        style.lineHeight = 16
        style.color = .primaryTextNeg
        style.letterSpacing = 0.1
    }

    static let bodyXSmallXSmallRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(12)
        style.lineHeight = 16
        style.color = .regularBody
        style.letterSpacing = 0.1
        style.alignment = .right
    }

    static let specialTabBarActive = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(11)
        style.lineHeight = 11
        style.color = .linksRegular
        style.alignment = .center
    }

    static let specialTabBarInactive = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.favoritStdBook!.withSize(11)
        style.lineHeight = 11
        style.color = .regularBody
        style.alignment = .center
    }
}
