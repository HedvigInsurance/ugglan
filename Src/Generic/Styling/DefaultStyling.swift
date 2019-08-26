//
//  DefaultStyling.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-03.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Form
import Foundation
import StoreKit
import UIKit

extension DefaultStyling {
    static func installCustom() {
        ListTableView.appearance().backgroundColor = .offWhite

        for view in [FormScrollView.self, FormTableView.self] {
            view.appearance(
                for: UITraitCollection(userInterfaceIdiom: .pad)
            ).backgroundColor = .secondaryBackground
            view.appearance().backgroundColor = .secondaryBackground
        }

        UIRefreshControl.appearance().tintColor = .primaryTintColor

        UINavigationBar.appearance().backgroundColor = .secondaryBackground
        UINavigationBar.appearance().tintColor = .primaryTintColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.primaryText,
            NSAttributedString.Key.font: HedvigFonts.circularStdBook!.withSize(16),
        ]

        UITabBar.appearance().unselectedItemTintColor = .offBlack
        UITabBar.appearance().tintColor = .primaryTintColor

        UITabBarItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: HedvigFonts.circularStdBook!.withSize(11),
            ],
            for: .normal
        )
        UITabBarItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: HedvigFonts.circularStdBook!.withSize(11),
            ],
            for: .selected
        )

        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .primaryTintColor

        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: HedvigFonts.circularStdBook!.withSize(16),
            ],
            for: .normal
        )

        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: HedvigFonts.circularStdBook!.withSize(16),
            ],
            for: .highlighted
        )

        UIBarButtonItem.appearance().tintColor = .primaryTintColor

        UINavigationBar.appearance().shadowImage = UIColor.primaryBorder.as1ptImage()
        UINavigationBar.appearance().barTintColor = UIColor.secondaryBackground

        UITabBar.appearance().barTintColor = UIColor.secondaryBackground
        UITabBar.appearance().backgroundImage = UIColor.secondaryBackground.as1ptImage()
        UITabBar.appearance().shadowImage = UIColor.primaryBorder.as1ptImage()

        UITabBarItem.appearance().setBadgeTextAttributes([
            NSAttributedString.Key.font: HedvigFonts.circularStdBook!.withSize(16),
        ], for: .normal)
        UITabBarItem.appearance().setBadgeTextAttributes([
            NSAttributedString.Key.font: HedvigFonts.circularStdBook!.withSize(16),
        ], for: .selected)

        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.primaryText,
            NSAttributedString.Key.font: HedvigFonts.circularStdBold!.withSize(30),
        ]

        current = .custom
    }

    static let custom = DefaultStyling(
        text: .default,
        field: FieldStyle(
            text: .default,
            placeholder: .default,
            disabled: .default,
            cursorColor: .turquoise
        ),
        detailText: .default,
        titleSubtitle: .default,
        button: .default,
        barButton: .default,
        switch: .default,
        segmentedControl: .default,
        sectionGrouped: .default,
        sectionPlain: .sectionPlain,
        formGrouped: .default,
        formPlain: .default,
        sectionBackground: .default,
        sectionBackgroundSelected: .default,
        scrollView: FormScrollView.self,
        plainTableView: ListTableView.self,
        groupedTableView: FormTableView.self,
        collectionView: UICollectionView.self
    )
}

final class FormScrollView: UIScrollView {}
final class FormTableView: UITableView {}
final class ListTableView: UITableView {}
