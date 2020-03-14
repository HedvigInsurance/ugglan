//
//  TextStyle.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-17.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Form
import Foundation
import ComponentKit

public extension TextStyle {
    static let chatBody = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(15)
        style.color = .hedvig(.primaryText)
    }

    static let chatBodyUnderlined = TextStyle.chatBody.restyled { (style: inout TextStyle) in
        style.setAttribute(
            NSUnderlineStyle.single.rawValue,
            for: NSAttributedString.Key.underlineStyle
        )
    }

    static let chatTimeStamp = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(12)
        style.color = .hedvig(.tertiaryText)
        style.lineSpacing = 2
    }

    static let body = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.color = .hedvig(.primaryText)
        style.lineSpacing = 4
    }

    static let bodyButtonText = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.color = .hedvig(.primaryText)
        style.lineSpacing = 4
        style.lineHeight = 20
    }

    static let bodyBoldButtonText = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(14)
        style.color = .hedvig(.primaryText)
        style.lineSpacing = 4
        style.lineHeight = 20
    }

    static let bodyOffBlack = TextStyle.body.restyled { (style: inout TextStyle) in
        style.color = .hedvig(.secondaryText)
    }

    static let toastBody = TextStyle.body.restyled { (style: inout TextStyle) in
        style.color = .hedvig(.secondaryText)
        style.font = HedvigFonts.circularStdBook!.withSize(15)
    }

    static let toastBodySubtitle = TextStyle.body.restyled { (style: inout TextStyle) in
        style.color = .hedvig(.secondaryText)
        style.font = HedvigFonts.circularStdBook!.withSize(12)
    }

    static let bodyWhite = TextStyle.body.restyled { (style: inout TextStyle) in
        style.color = .hedvig(.white)
    }

    static let bodyBold = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(14)
        style.color = .hedvig(.primaryText)
        style.lineSpacing = 4
    }

    static let navigationSubtitleWhite = TextStyle.body.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(13)
        style.lineSpacing = 4
        style.color = .hedvig(.white)
    }

    static let centeredBody = TextStyle.body.restyled { (style: inout TextStyle) in
        style.alignment = .center
    }

    static let centeredBodyOffBlack = TextStyle.bodyOffBlack.restyled { (style: inout TextStyle) in
        style.alignment = .center
    }

    static let sectionHeader = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(15)
        style.color = .hedvig(.darkGray)
    }

    static let standaloneLargeTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.soRayExtraBold!.withSize(24)
        style.color = .hedvig(.primaryText)
    }

    static let blockRowTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(17)
        style.color = .hedvig(.primaryText)
    }

    static let offerBubbleTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(16)
        style.color = .hedvig(.white)
        style.alignment = .center
    }

    static let offerBubbleSubtitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.color = .hedvig(.white)
        style.alignment = .center
    }

    static let blockRowDescription = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.color = .hedvig(.secondaryText)
    }

    static let headingOne = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(40)
        style.color = .hedvig(.primaryText)
    }

    static let centeredHeadingOne = TextStyle.headingOne.restyled { (style: inout TextStyle) in
        style.alignment = .center
    }

    static let smallTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.color = .hedvig(.secondaryText)
    }

    static let boldSmallTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(16)
        style.color = .hedvig(.primaryText)
    }

    static let priceBubbleGrossTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.color = .hedvig(.darkGray)
        style.alignment = .center
        style.setAttribute(NSUnderlineStyle.single.rawValue, for: NSAttributedString.Key.strikethroughStyle)
    }

    static let largePriceBubbleTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(60)
        style.color = .hedvig(.primaryText)
        style.alignment = .center
    }

    static let reallySmallTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(13)
        style.color = .hedvig(.darkGray)
    }

    static let perilTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(12)
        style.color = .hedvig(.decorText)
    }

    static let rowTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .hedvig(.primaryText)
    }

    static let rowTitleBold = TextStyle.rowTitle.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(17)
    }

    static let rowTitleSecondary = TextStyle.rowTitle.restyled { (style: inout TextStyle) in
        style.color = .hedvig(.secondaryText)
    }

    static let rowTitleDisabled = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .hedvig(.gray)
    }

    static let rowValueLink = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .hedvig(.primaryTintColor)
    }

    static let rowSubtitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.color = .hedvig(.secondaryText)
    }

    static let rowTertitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(12)
        style.color = .hedvig(.secondaryText)
    }

    static let rowSubtitlePrimary = TextStyle.rowSubtitle.restyled { (style: inout TextStyle) in
        style.color = .hedvig(.primaryText)
    }

    static let rowValueEditable = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .hedvig(.primaryTintColor)
    }

    static let rowValueEditableMuted = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .hedvig(.primaryText)
    }

    static let rowValueEditablePlaceholder = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .hedvig(.primaryTextMuted)
    }

    static let rowValueEditableRight = TextStyle.rowValueEditable.restyled { (style: inout TextStyle) in
        style.alignment = .right
    }

    static let dangerButton = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(15)
        style.color = .hedvig(.pink)
    }

    static let normalButton = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(15)
        style.color = .hedvig(.primaryTintColor)
    }

    static let navigationBarButton = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .hedvig(.primaryTintColor)
    }

    static let navigationBarButtonSkip = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .hedvig(.pink)
    }

    static let navigationBarButtonPrimary = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(17)
        style.color = .hedvig(.primaryTintColor)
    }

    static let draggableOverlayTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.soRayExtraBold!.withSize(24)
        style.color = .hedvig(.primaryText)
    }

    static let countdownNumber = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.soRayExtraBold!.withSize(40)
        style.color = .hedvig(.pink)
    }

    static let countdownLetter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(12)
        style.color = .hedvig(.primaryText)
    }

    static let offerSummaryTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(23)
        style.color = .hedvig(.violet200)
        style.lineHeight = 24
    }

    static let draggableOverlayDescription = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.secondaryText)
    }

    static let headerLargeTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(30)
        style.lineHeight = 32
        style.color = .hedvig(.primaryText)
    }

    static let headlineLargeLargeRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.soRayExtraBold!.withSize(24)
        style.lineHeight = 24
        style.alignment = .right
        style.color = .hedvig(.primaryText)
    }

    static let headlineLargeLargeLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.soRayExtraBold!.withSize(24)
        style.lineHeight = 24
        style.color = .hedvig(.primaryText)
    }

    static let headlineLargeNegLargeNegLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.soRayExtraBold!.withSize(24)
        style.lineHeight = 24
        style.color = .hedvig(.primaryTextNeg)
    }

    static let headlineLargeLargeCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.soRayExtraBold!.withSize(24)
        style.lineHeight = 24
        style.color = .hedvig(.primaryText)
        style.alignment = .center
    }

    static let headlineLargeNegLargeNegCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.soRayExtraBold!.withSize(24)
        style.lineHeight = 24
        style.color = .hedvig(.primaryTextNeg)
        style.alignment = .center
    }

    static let headlineLargeNegLargeNegRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.soRayExtraBold!.withSize(24)
        style.lineHeight = 24
        style.color = .hedvig(.primaryTextNeg)
        style.alignment = .right
    }

    static let headlineMediumNegMediumNegRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(16)
        style.lineHeight = 24
        style.color = .hedvig(.primaryTextNeg)
        style.alignment = .right
    }

    static let headlineMediumNegMediumNegLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(16)
        style.lineHeight = 24
        style.color = .hedvig(.primaryTextNeg)
    }

    static let headlineMediumMediumLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(16)
        style.lineHeight = 24
        style.color = .hedvig(.primaryText)
    }

    static let headlineMediumMediumRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(16)
        style.lineHeight = 24
        style.color = .hedvig(.primaryText)
        style.alignment = .right
    }

    static let headlineMediumNegMediumNegCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(16)
        style.lineHeight = 24
        style.color = .hedvig(.primaryTextNeg)
        style.alignment = .center
    }

    static let headlineMediumMediumCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(16)
        style.lineHeight = 24
        style.color = .hedvig(.primaryText)
        style.alignment = .center
    }

    static let linksRegularCautionRegularLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.lineHeight = 24
        style.letterSpacing = 0.2
        style.color = .hedvig(.regularCaution)
    }

    static let linksRegularRegularRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.lineHeight = 24
        style.letterSpacing = 0.2
        style.color = .hedvig(.linksRegular)
    }

    static let headerRegularTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.lineHeight = 18
        style.color = .hedvig(.primaryText)
    }

    static let linksRegularRegularLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.lineHeight = 18
        style.color = .hedvig(.linksRegular)
    }

    static let bodyRegularRegularLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.lineHeight = 18
        style.color = .hedvig(.regularBody)
    }

    static let bodyRegularNegRegularNegCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.lineHeight = 24
        style.letterSpacing = 0.2
        style.color = .hedvig(.regularBody)
        style.alignment = .center
    }

    static let linksRegularRegularCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.lineHeight = 24
        style.color = .hedvig(.linksRegular)
        style.letterSpacing = 0.2
        style.alignment = .center
    }

    static let bodyRegularRegularCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.alignment = .center
        style.lineHeight = 24
        style.color = .hedvig(.regularBody)
        style.letterSpacing = 0.2
    }

    static let bodyRegularNegRegularNegLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.lineHeight = 24
        style.color = .hedvig(.primaryTextNeg)
        style.letterSpacing = 0.2
    }

    static let bodyRegularRegularRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.lineHeight = 24
        style.color = .hedvig(.regularBody)
        style.letterSpacing = 0.2
        style.alignment = .right
    }

    static let bodyRegularNegRegularNegRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.lineHeight = 24
        style.color = .hedvig(.primaryTextNeg)
        style.letterSpacing = 0.2
        style.alignment = .right
    }

    static let linksRegularCautionRegularRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.lineHeight = 24
        style.letterSpacing = 0.2
        style.color = .hedvig(.linksRegular)
        style.alignment = .right
    }

    static let linksRegularCautionRegularCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.lineHeight = 24
        style.letterSpacing = 0.2
        style.color = .hedvig(.linksRegular)
        style.alignment = .center
    }

    static let headLineSmallSmallCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.primaryText)
        style.alignment = .center
    }

    static let headlineSmallNegSmallNegRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.primaryTextNeg)
        style.alignment = .right
    }

    static let headlineSmallSmallRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.primaryText)
        style.alignment = .right
    }

    static let headlineSmallSmallLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.primaryText)
    }

    static let headlineSmallNegSmallNegCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.primaryTextNeg)
        style.alignment = .center
    }

    static let headlineSmallNegSmallNegLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.primaryTextNeg)
    }

    static let bodySmallNegSmallNegRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.primaryTextNeg)
        style.letterSpacing = 0.2
        style.alignment = .right
    }

    static let linksSmallCautionSmallCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.regularCaution)
        style.letterSpacing = 0.2
        style.alignment = .center
    }

    static let bodySmallSmallRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.regularBody)
        style.letterSpacing = 0.2
        style.alignment = .right
    }

    static let linksSmallSmallCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.linksRegular)
        style.letterSpacing = 0.2
        style.alignment = .center
    }

    static let bodySmallNegSmallNegLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.primaryTextNeg)
        style.letterSpacing = 0.2
    }

    static let linksSmallSmallRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.linksRegular)
        style.letterSpacing = 0.2
    }

    static let bodySmallSmallCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.regularBody)
        style.letterSpacing = 0.2
        style.alignment = .center
    }

    static let bodySmallSmallLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.regularBody)
        style.letterSpacing = 0.2
    }

    static let bodySmallNegSmallNegCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.primaryTextNeg)
        style.letterSpacing = 0.2
        style.alignment = .center
    }

    static let linksSmallCautionSmallLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.regularCaution)
        style.letterSpacing = 0.2
    }

    static let linksSmallCautionSmallRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.regularCaution)
        style.letterSpacing = 0.2
        style.alignment = .right
    }

    static let linksSmallSmallLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.lineHeight = 20
        style.color = .hedvig(.linksRegular)
        style.letterSpacing = 0.2
    }

    static let bodyXSmallNegXSmallNegCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(12)
        style.lineHeight = 16
        style.color = .hedvig(.primaryTextNeg)
        style.letterSpacing = 0.1
        style.alignment = .center
    }

    static let bodyXSmallXSmallCenter = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(12)
        style.lineHeight = 16
        style.color = .hedvig(.regularBody)
        style.letterSpacing = 0.1
        style.alignment = .center
    }

    static let bodyXSmallNegXSmallNegRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(12)
        style.lineHeight = 16
        style.color = .hedvig(.primaryTextNeg)
        style.letterSpacing = 0.1
        style.alignment = .right
    }

    static let bodyXSmallXSmallLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(12)
        style.lineHeight = 16
        style.color = .hedvig(.regularBody)
        style.letterSpacing = 0.1
    }

    static let bodyXSmallNegXSmallNegLeft = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(12)
        style.lineHeight = 16
        style.color = .hedvig(.primaryTextNeg)
        style.letterSpacing = 0.1
    }

    static let bodyXSmallXSmallRight = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(12)
        style.lineHeight = 16
        style.color = .hedvig(.regularBody)
        style.letterSpacing = 0.1
        style.alignment = .right
    }

    static let specialTabBarActive = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(11)
        style.lineHeight = 11
        style.color = .hedvig(.linksRegular)
        style.alignment = .center
    }

    static let specialTabBarInactive = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(11)
        style.lineHeight = 11
        style.color = .hedvig(.regularBody)
        style.alignment = .center
    }
}
