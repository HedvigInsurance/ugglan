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
    static let body = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(15)
        style.color = .black
    }

    static let bodyOffBlack = TextStyle.body.restyled { (style: inout TextStyle) in
        style.color = .offBlack
        style.lineSpacing = 4
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
        style.color = .black
    }

    static let blockRowTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(17)
        style.color = .black
    }

    static let blockRowDescription = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.color = .offBlack
    }

    static let headingOne = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(40)
        style.color = .blackPurple
    }

    static let centeredHeadingOne = TextStyle.headingOne.restyled { (style: inout TextStyle) in
        style.alignment = .center
    }
    
    static let smallTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(16)
        style.color = .offBlack
    }

    static let boldSmallTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(16)
        style.color = .black
    }
    
    static let perilTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(12)
        style.color = .gray
    }

    static let rowTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .black
    }

    static let rowTitleWhite = TextStyle.rowTitle.restyled { (style: inout TextStyle) in
        style.color = .white
    }

    static let rowTitleDisabled = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .gray
    }

    static let rowValueLink = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .purple
    }

    static let rowSubtitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.color = .offBlack
    }

    static let rowSubtitleWhite = TextStyle.rowSubtitle.restyled { (style: inout TextStyle) in
        style.color = .white
    }

    static let rowValueEditable = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .purple
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
        style.color = .purple
    }

    static let navigationBarButton = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .purple
    }

    static let navigationBarButtonPrimary = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(17)
        style.color = .purple
    }
    
    static let drabbableOverlayTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(18)
        style.color = .black
    }
}
