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

    static let blockRowTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBold!.withSize(19)
        style.color = .black
    }

    static let blockRowDescription = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(13)
        style.color = .offBlack
    }

    static let rowTitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .black
    }

    static let rowTitleDisabled = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(17)
        style.color = .gray
    }

    static let rowSubtitle = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(14)
        style.color = .offBlack
    }

    static let dangerButton = TextStyle.default.restyled { (style: inout TextStyle) in
        style.font = HedvigFonts.circularStdBook!.withSize(15)
        style.color = .pink
    }
}
