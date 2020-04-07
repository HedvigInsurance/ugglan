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
        ListTableView.appearance().backgroundColor = .primaryBackground

        for view in [FormScrollView.self, FormTableView.self] {
            view.appearance(
                for: UITraitCollection(userInterfaceIdiom: .pad)
            ).backgroundColor = .primaryBackground
            view.appearance().backgroundColor = .primaryBackground
        }

        UIRefreshControl.appearance().tintColor = UIColor(dynamic: { trait in
            trait.userInterfaceStyle == .dark ? .white : .primaryTintColor
        })

        UINavigationBar.appearance().tintColor = .primaryTintColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.primaryText,
            NSAttributedString.Key.font: HedvigFonts.favoritStdBook!.withSize(16),
        ]
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.primaryText,
            NSAttributedString.Key.font: HedvigFonts.favoritStdBook!.withSize(30),
        ]

        if #available(iOS 13.0, *) {
            UINavigationBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .dark)
            ).shadowImage = UIColor.transparent.as1ptImage()

            UINavigationBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .light)
            ).shadowImage = UIColor.transparent.as1ptImage()
        } else {
            UINavigationBar.appearance().shadowImage = UIColor.transparent.as1ptImage()
        }

        UINavigationBar.appearance().barTintColor = UIColor.primaryBackground

        UITabBar.appearance().unselectedItemTintColor = .disabledTintColor
        UITabBar.appearance().tintColor = .primaryTintColor

        UITabBarItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: HedvigFonts.favoritStdBook!.withSize(11),
            ],
            for: .normal
        )
        UITabBarItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: HedvigFonts.favoritStdBook!.withSize(11),
            ],
            for: .selected
        )

        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .primaryTintColor

        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: HedvigFonts.favoritStdBook!.withSize(16),
            ],
            for: .normal
        )

        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: HedvigFonts.favoritStdBook!.withSize(16),
            ],
            for: .highlighted
        )

        UIBarButtonItem.appearance().tintColor = .primaryTintColor

        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        barButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .highlighted)

        UITabBar.appearance().barTintColor = UIColor.primaryBackground

        if #available(iOS 13.0, *) {
            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .dark)
            ).backgroundImage = UIColor.almostBlack.as1ptImage()

            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .light)
            ).backgroundImage = UIColor.offWhite.as1ptImage()

            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .dark)
            ).shadowImage = UIColor.almostBlack.as1ptImage()

            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .light)
            ).shadowImage = UIColor.offWhite.as1ptImage()

            UINavigationBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .light)
            ).backIndicatorImage = Asset.backButton.image.withConfiguration(UITraitCollection(userInterfaceStyle: .light).imageConfiguration)
            UINavigationBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .light)
            ).backIndicatorTransitionMaskImage = Asset.backButton.image.withConfiguration(UITraitCollection(userInterfaceStyle: .light).imageConfiguration)

            UINavigationBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .dark)
            ).backIndicatorImage = Asset.backButton.image.withConfiguration(UITraitCollection(userInterfaceStyle: .dark).imageConfiguration)
            UINavigationBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .dark)
            ).backIndicatorTransitionMaskImage = Asset.backButton.image.withConfiguration(UITraitCollection(userInterfaceStyle: .dark).imageConfiguration)
        } else {
            UITabBar.appearance().backgroundImage = UIColor.primaryBackground.as1ptImage()
            UITabBar.appearance().shadowImage = UIColor.primaryBorder.as1ptImage()
            UINavigationBar.appearance().backIndicatorImage = Asset.backButton.image
            UINavigationBar.appearance().backIndicatorTransitionMaskImage = Asset.backButton.image
        }

        UITabBarItem.appearance().setBadgeTextAttributes([
            NSAttributedString.Key.font: HedvigFonts.favoritStdBook!.withSize(16),
        ], for: .normal)
        UITabBarItem.appearance().setBadgeTextAttributes([
            NSAttributedString.Key.font: HedvigFonts.favoritStdBook!.withSize(16),
        ], for: .selected)
        
        UIImageView.appearance().tintColor = .primaryTintColor

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
