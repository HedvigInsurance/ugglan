//
//  SectionStyle.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-05.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Form
import Foundation
import UIKit

extension BorderStyle {
    static let standard = BorderStyle(
        width: 1 / UIScreen.main.scale,
        color: .primaryBorder,
        cornerRadius: 0,
        borderEdges: [UIRectEdge.bottom, UIRectEdge.top]
    )

    static let standardRounded = BorderStyle(
        width: 0,
        color: .transparent,
        cornerRadius: 5,
        borderEdges: [UIRectEdge.top, UIRectEdge.bottom, UIRectEdge.left, UIRectEdge.right]
    )
}

extension BackgroundStyle {
    static let primaryDark = BackgroundStyle(
        color: UIColor.secondaryBackground.resolvedColorOrFallback(
            with: UITraitCollection(userInterfaceStyle: .dark)
        ),
        border: .standard
    )

    static let primaryLight = BackgroundStyle(
        color: UIColor.secondaryBackground.resolvedColorOrFallback(
            with: UITraitCollection(userInterfaceStyle: .light)
        ),
        border: .standard
    )

    static let turquoise = BackgroundStyle(color: .turquoise, border: .standard)

    static let primaryDarkRoundedBorder = BackgroundStyle(
        color: UIColor.secondaryBackground.resolvedColorOrFallback(
            with: UITraitCollection(userInterfaceStyle: .dark)
        ),
        border: .standardRounded
    )

    static let primaryLightRoundedBorder = BackgroundStyle(
        color: UIColor.secondaryBackground.resolvedColorOrFallback(
            with: UITraitCollection(userInterfaceStyle: .light)
        ),
        border: .standardRounded
    )

    static let purple = BackgroundStyle(
        color: UIColor.purple,
        border: .standard
    )

    static let blackOpaque = BackgroundStyle(
        color: UIColor.black.withAlphaComponent(0.2),
        border: .standard
    )

    static let blackOpaqueRoundedBorder = BackgroundStyle(
        color: UIColor.black.withAlphaComponent(0.2),
        border: .standardRounded
    )

    static let pink = BackgroundStyle(
        color: UIColor.pink.withAlphaComponent(0.2),
        border: .standard
    )

    static let pinkRoundedBorder = BackgroundStyle(
        color: UIColor.pink.withAlphaComponent(0.2),
        border: .standardRounded
    )

    static let invisible = BackgroundStyle(
        color: UIColor.clear,
        border: BorderStyle.none
    )
}

extension SeparatorStyle {
    static let darkGray = SeparatorStyle(width: 0.25, color: .primaryBorder)
}

extension InsettedStyle where Style == SeparatorStyle {
    static let inset = InsettedStyle(
        style: .darkGray,
        insets: UIEdgeInsets(
            top: 0,
            left: SectionStyle.sectionPlainRowInsets.left,
            bottom: 0,
            right: 0
        )
    )

    static let insetLargeIcons = InsettedStyle(
        style: .darkGray,
        insets: UIEdgeInsets(
            top: 0,
            left: SectionStyle.sectionPlainRowInsets.left + 60,
            bottom: 0,
            right: 0
        )
    )

    static let insetMediumIcons = InsettedStyle(
        style: .darkGray,
        insets: UIEdgeInsets(
            top: 0,
            left: SectionStyle.sectionPlainRowInsets.left + 45,
            bottom: 0,
            right: 0
        )
    )
}

extension SectionBackgroundStyle {
    static let primaryLight = SectionBackgroundStyle(
        background: .primaryLight,
        topSeparator: .inset,
        bottomSeparator: .inset
    )

    static let primaryDark = SectionBackgroundStyle(
        background: .primaryDark,
        topSeparator: .inset,
        bottomSeparator: .inset
    )

    static var primaryLightLargeIcons = SectionBackgroundStyle(
        background: .primaryLight,
        topSeparator: .insetLargeIcons,
        bottomSeparator: .insetLargeIcons
    )

    static var primaryDarkLargeIcons = SectionBackgroundStyle(
        background: .primaryDark,
        topSeparator: .insetLargeIcons,
        bottomSeparator: .insetLargeIcons
    )

    static let primaryDarkLargeIconsRoundedBorder = SectionBackgroundStyle(
        background: .primaryDarkRoundedBorder,
        topSeparator: .insetLargeIcons,
        bottomSeparator: .insetLargeIcons
    )

    static let primaryLightLargeIconsRoundedBorder = SectionBackgroundStyle(
        background: .primaryLightRoundedBorder,
        topSeparator: .insetLargeIcons,
        bottomSeparator: .insetLargeIcons
    )

    static let primaryLightMediumIcons = SectionBackgroundStyle(
        background: .primaryLight,
        topSeparator: .insetMediumIcons,
        bottomSeparator: .insetMediumIcons
    )

    static let primaryDarkMediumIcons = SectionBackgroundStyle(
        background: .primaryDark,
        topSeparator: .insetMediumIcons,
        bottomSeparator: .insetMediumIcons
    )

    static let primaryLightRoundedBorder = SectionBackgroundStyle(
        background: .primaryLightRoundedBorder,
        topSeparator: .inset,
        bottomSeparator: .inset
    )

    static let primaryDarkRoundedBorder = SectionBackgroundStyle(
        background: .primaryDarkRoundedBorder,
        topSeparator: .inset,
        bottomSeparator: .inset
    )

    static let purple = SectionBackgroundStyle(
        background: .purple,
        topSeparator: .inset,
        bottomSeparator: .inset
    )

    static let blackOpaque = SectionBackgroundStyle(
        background: .blackOpaque,
        topSeparator: .inset,
        bottomSeparator: .inset
    )

    static let blackOpaqueLargeIcons = SectionBackgroundStyle(
        background: .blackOpaque,
        topSeparator: .insetLargeIcons,
        bottomSeparator: .insetLargeIcons
    )

    static let blackOpaqueRoundedBorder = SectionBackgroundStyle(
        background: .blackOpaqueRoundedBorder,
        topSeparator: .inset,
        bottomSeparator: .inset
    )

    static let pink = SectionBackgroundStyle(
        background: .pink,
        topSeparator: .inset,
        bottomSeparator: .inset
    )

    static let pinkRoundedBorder = SectionBackgroundStyle(
        background: .pinkRoundedBorder,
        topSeparator: .inset,
        bottomSeparator: .inset
    )

    static let invisible = SectionBackgroundStyle(
        background: .invisible,
        topSeparator: .none,
        bottomSeparator: .none
    )
}

extension SectionStyle.Background {
    static let standardLight = SectionStyle.Background(style: .primaryLight)
    static let standardDark = SectionStyle.Background(style: .primaryDark)
    static let highlighted = SectionStyle.Background(style: .purple)
    static let standardDarkLargeIcons = SectionStyle.Background(style: .primaryDarkLargeIcons)
    static let standardLightLargeIcons = SectionStyle.Background(style: .primaryLightLargeIcons)

    static let standardLightLargeIconsRoundedBorder = SectionStyle.Background(style: .primaryLightLargeIconsRoundedBorder)
    static let standardDarkLargeIconsRoundedBorder = SectionStyle.Background(style: .primaryDarkLargeIconsRoundedBorder)
    static let standardLightMediumIcons = SectionStyle.Background(style: .primaryLightMediumIcons)
    static let standardDarkMediumIcons = SectionStyle.Background(style: .primaryDarkMediumIcons)

    static let standardLightRoundedBorder = SectionStyle.Background(style: .primaryLightRoundedBorder)
    static let standardDarkRoundedBorder = SectionStyle.Background(style: .primaryDarkRoundedBorder)

    static let selected = SectionStyle.Background(style: .blackOpaque)
    static let selectedLargeIcons = SectionStyle.Background(style: .blackOpaqueLargeIcons)
    static let selectedRoundedBorder = SectionStyle.Background(style: .blackOpaqueRoundedBorder)
    static let selectedDanger = SectionStyle.Background(style: .pink)
    static let selectedDangerRoundedBorder = SectionStyle.Background(style: .pinkRoundedBorder)
    static let invisible = SectionStyle.Background(style: .invisible)
}

extension HeaderFooterStyle {
    static let standard = HeaderFooterStyle(
        text: .sectionHeader,
        backgroundImage: nil,
        insets: UIEdgeInsets(
            top: 15,
            left: 5,
            bottom: 10,
            right: 5
        ),
        emptyHeight: 0
    )
}

extension SectionStyle {
    static let sectionPlainRowInsets = UIEdgeInsets(
        top: 15,
        left: 15,
        bottom: 15,
        right: 15
    )

    static let sectionPlainItemSpacing: CGFloat = 10
    static let sectionPlainMinRowHeight: CGFloat = 0

    static let sectionPlainDark = SectionStyle(
        rowInsets: SectionStyle.sectionPlainRowInsets,
        itemSpacing: SectionStyle.sectionPlainItemSpacing,
        minRowHeight: SectionStyle.sectionPlainMinRowHeight,
        background: .standardDark,
        selectedBackground: .selected,
        header: .standard,
        footer: .standard
    )

    static let sectionPlainLight = SectionStyle(
        rowInsets: SectionStyle.sectionPlainRowInsets,
        itemSpacing: SectionStyle.sectionPlainItemSpacing,
        minRowHeight: SectionStyle.sectionPlainMinRowHeight,
        background: .standardLight,
        selectedBackground: .selected,
        header: .standard,
        footer: .standard
    )

    static let sectionPlainLightRoundedBorder = SectionStyle(
        rowInsets: SectionStyle.sectionPlainRowInsets,
        itemSpacing: SectionStyle.sectionPlainItemSpacing,
        minRowHeight: SectionStyle.sectionPlainMinRowHeight,
        background: .standardLightRoundedBorder,
        selectedBackground: .selectedRoundedBorder,
        header: .standard,
        footer: .standard
    )

    static let sectionPlainDarkRoundedBorder = SectionStyle(
        rowInsets: SectionStyle.sectionPlainRowInsets,
        itemSpacing: SectionStyle.sectionPlainItemSpacing,
        minRowHeight: SectionStyle.sectionPlainMinRowHeight,
        background: .standardDarkRoundedBorder,
        selectedBackground: .selectedRoundedBorder,
        header: .standard,
        footer: .standard
    )

    static let sectionPlainLargeIconsLight = SectionStyle(
        rowInsets: SectionStyle.sectionPlainRowInsets,
        itemSpacing: SectionStyle.sectionPlainItemSpacing,
        minRowHeight: SectionStyle.sectionPlainMinRowHeight,
        background: .standardLightLargeIcons,
        selectedBackground: .selectedLargeIcons,
        header: .standard,
        footer: .standard
    )

    static let sectionPlainLargeIconsDark = SectionStyle(
        rowInsets: SectionStyle.sectionPlainRowInsets,
        itemSpacing: SectionStyle.sectionPlainItemSpacing,
        minRowHeight: SectionStyle.sectionPlainMinRowHeight,
        background: .standardDarkLargeIcons,
        selectedBackground: .selectedLargeIcons,
        header: .standard,
        footer: .standard
    )

    static let sectionPlainDarkLargeIconsRoundedBorder = SectionStyle(
        rowInsets: SectionStyle.sectionPlainRowInsets,
        itemSpacing: SectionStyle.sectionPlainItemSpacing,
        minRowHeight: SectionStyle.sectionPlainMinRowHeight,
        background: .standardDarkLargeIconsRoundedBorder,
        selectedBackground: .selectedRoundedBorder,
        header: .standard,
        footer: .standard
    )

    static let sectionPlainLightLargeIconsRoundedBorder = SectionStyle(
        rowInsets: SectionStyle.sectionPlainRowInsets,
        itemSpacing: SectionStyle.sectionPlainItemSpacing,
        minRowHeight: SectionStyle.sectionPlainMinRowHeight,
        background: .standardLightLargeIconsRoundedBorder,
        selectedBackground: .selectedRoundedBorder,
        header: .standard,
        footer: .standard
    )
}

extension DynamicFormStyle {
    static let `default` = DynamicFormStyle { _ -> FormStyle in
        FormStyle(insets: UIEdgeInsets(horizontalInset: 20, verticalInset: 15))
    }

    static let noInsets = DynamicFormStyle { _ -> FormStyle in
        FormStyle(insets: .zero)
    }
}

extension DynamicSectionStyle {
    static let sectionPlainRounded = DynamicSectionStyle { trait -> SectionStyle in
        trait.userInterfaceStyle == .dark ? .sectionPlainDarkRoundedBorder : .sectionPlainLightRoundedBorder
    }

    static let sectionPlain = DynamicSectionStyle { trait -> SectionStyle in
        Self.sectionPlainRounded.styleGenerator(trait)
    }

    static let sectionPlainLargeIcons = DynamicSectionStyle { trait -> SectionStyle in
        trait.userInterfaceStyle == .dark ? .sectionPlainDarkLargeIconsRoundedBorder : .sectionPlainLightLargeIconsRoundedBorder
    }
}
