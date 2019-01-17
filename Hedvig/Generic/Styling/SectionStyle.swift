//
//  SectionStyle.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-05.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Form
import Foundation

extension BorderStyle {
    static let standard = BorderStyle(
        width: 1 / UIScreen.main.scale,
        color: .grayBorder,
        cornerRadius: 0,
        borderEdges: [UIRectEdge.bottom, UIRectEdge.top]
    )
}

extension BackgroundStyle {
    static let white = BackgroundStyle(color: .white, border: .standard)
    static let purple = BackgroundStyle(
        color: UIColor.purple.withAlphaComponent(0.2),
        border: .standard
    )
}

extension SeparatorStyle {
    static let darkGray = SeparatorStyle(width: 0.25, color: .grayBorder)
}

extension InsettedStyle where Style == SeparatorStyle {
    static let inset = InsettedStyle(
        style: .darkGray,
        insets: UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0
        )
    )
}

extension SectionBackgroundStyle {
    static let white = SectionBackgroundStyle(
        background: .white,
        topSeparator: .inset,
        bottomSeparator: .inset
    )

    static let purple = SectionBackgroundStyle(
        background: .purple,
        topSeparator: .inset,
        bottomSeparator: .inset
    )
}

extension SectionStyle.Background {
    static let standard = SectionStyle.Background(style: .white)
    static let selected = SectionStyle.Background(style: .purple)
}

extension HeaderFooterStyle {
    static let standard = HeaderFooterStyle(
        text: .sectionHeader,
        backgroundImage: nil,
        insets: UIEdgeInsets(
            top: 15,
            left: 15,
            bottom: 10,
            right: 15
        ),
        emptyHeight: 0
    )
}

extension SectionStyle {
    static let sectionPlain = SectionStyle(
        rowInsets: UIEdgeInsets(
            top: 15,
            left: 15,
            bottom: 15,
            right: 15
        ),
        itemSpacing: 10,
        minRowHeight: 0,
        background: .standard,
        selectedBackground: .selected,
        header: .standard,
        footer: .standard
    )
}

extension DynamicSectionStyle {
    static let sectionPlain = DynamicSectionStyle { _ -> SectionStyle in
        return .sectionPlain
    }
}
