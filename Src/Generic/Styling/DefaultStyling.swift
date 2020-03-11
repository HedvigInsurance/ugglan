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
import ComponentKit

extension DefaultStyling {
    static func installCustom() {
        Button.font = HedvigFonts.circularStdBook!
        
        ListTableView.appearance().backgroundColor = .hedvig(.primaryBackground)

        for view in [FormScrollView.self, FormTableView.self] {
            view.appearance(
                for: UITraitCollection(userInterfaceIdiom: .pad)
            ).backgroundColor = .hedvig(.primaryBackground)
            view.appearance().backgroundColor = .hedvig(.primaryBackground)
        }

        UIRefreshControl.appearance().tintColor = UIColor(dynamic: { trait in
            trait.userInterfaceStyle == .dark ? .hedvig(.white) : .hedvig(.primaryTintColor)
        })

        UINavigationBar.appearance().tintColor = .hedvig(.primaryTintColor)
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.hedvig(.primaryText),
            NSAttributedString.Key.font: HedvigFonts.circularStdBook!.withSize(16),
        ]
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.hedvig(.primaryText),
            NSAttributedString.Key.font: HedvigFonts.circularStdBold!.withSize(30),
        ]

        if #available(iOS 13.0, *) {
            UINavigationBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .dark)
            ).shadowImage = UIColor.hedvig(.transparent).as1ptImage()

            UINavigationBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .light)
            ).shadowImage = UIColor.hedvig(.transparent).as1ptImage()
        } else {
            UINavigationBar.appearance().shadowImage = UIColor.hedvig(.transparent).as1ptImage()
        }

        UINavigationBar.appearance().barTintColor = UIColor.hedvig(.primaryBackground)

        UITabBar.appearance().unselectedItemTintColor = .hedvig(.disabledTintColor)
        UITabBar.appearance().tintColor = .hedvig(.primaryTintColor)

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

        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .hedvig(.primaryTintColor)

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

        UIBarButtonItem.appearance().tintColor = .hedvig(.primaryTintColor)

        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        barButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .highlighted)

        UITabBar.appearance().barTintColor = UIColor.hedvig(.primaryBackground)

        if #available(iOS 13.0, *) {
            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .dark)
            ).backgroundImage = UIColor.hedvig(.almostBlack).as1ptImage()

            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .light)
            ).backgroundImage = UIColor.hedvig(.offWhite).as1ptImage()

            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .dark)
            ).shadowImage = UIColor.hedvig(.almostBlack).as1ptImage()

            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .light)
            ).shadowImage = UIColor.hedvig(.offWhite).as1ptImage()

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
            UITabBar.appearance().backgroundImage = UIColor.hedvig(.primaryBackground).as1ptImage()
            UITabBar.appearance().shadowImage = UIColor.hedvig(.primaryBorder).as1ptImage()
            UINavigationBar.appearance().backIndicatorImage = Asset.backButton.image
            UINavigationBar.appearance().backIndicatorTransitionMaskImage = Asset.backButton.image
        }
                
        UITabBarItem.appearance().setBadgeTextAttributes([
            NSAttributedString.Key.font: HedvigFonts.circularStdBook!.withSize(16),
        ], for: .normal)
        UITabBarItem.appearance().setBadgeTextAttributes([
            NSAttributedString.Key.font: HedvigFonts.circularStdBook!.withSize(16),
        ], for: .selected)

        current = .custom
    }

    static let custom = DefaultStyling(
        text: .default,
        field: FieldStyle(
            text: .default,
            placeholder: .default,
            disabled: .default,
            cursorColor: .hedvig(.turquoise)
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
