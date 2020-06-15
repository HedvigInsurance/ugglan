//
//  DefaultStyling.swift
//  hCoreUI
//
//  Created by sam on 2.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Form
import Foundation
import StoreKit
import UIKit

public extension DefaultStyling {
    static func installCustom() {
        ListTableView.appearance().backgroundColor = .brand(.primaryBackground())

        for view in [FormScrollView.self, FormTableView.self] {
            view.appearance(
                for: UITraitCollection(userInterfaceIdiom: .pad)
            ).backgroundColor = .brand(.primaryBackground())
            view.appearance().backgroundColor = .brand(.primaryBackground())

            if #available(iOS 13.0, *) {
                view.appearance(for: UITraitCollection(userInterfaceLevel: .elevated)).backgroundColor = .brand(.secondaryBackground())
            }
        }
        
        UIRefreshControl.appearance().tintColor = .brand(.primaryTintColor)
        UINavigationBar.appearance().barTintColor = .brand(.primaryBackground())

        if #available(iOS 13.0, *) {
            UINavigationBar.appearance().isTranslucent = false

            func generateAppearanceFor(userInterfaceLevel: UIUserInterfaceLevel) -> UINavigationBarAppearance {
                let appearance = UINavigationBarAppearance()
                appearance.backgroundColor = userInterfaceLevel == .elevated ? .brand(.secondaryBackground()) : .brand(.primaryBackground())
                appearance.shadowImage = UIColor.clear.asImage()
                appearance.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.brand(.primaryText()),
                    NSAttributedString.Key.font: Fonts.fontFor(style: .headline),
                ]
                appearance.largeTitleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.brand(.primaryText()),
                    NSAttributedString.Key.font: Fonts.fontFor(style: .largeTitle),
                ]
                
                appearance.setBackIndicatorImage(hCoreUIAssets.backButton.image, transitionMaskImage: hCoreUIAssets.backButton.image)
                appearance.backButtonAppearance.normal.titleTextAttributes = [
                    .foregroundColor: UIColor.clear
                ]
                
                return appearance
            }

            let baseAppearance = generateAppearanceFor(userInterfaceLevel: .base)

            UINavigationBar.appearance().standardAppearance = baseAppearance
            UINavigationBar.appearance().compactAppearance = baseAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = baseAppearance

            let elevatedAppearance = generateAppearanceFor(userInterfaceLevel: .elevated)

            UINavigationBar.appearance(for: UITraitCollection(userInterfaceLevel: .elevated)).standardAppearance = elevatedAppearance
            UINavigationBar.appearance(for: UITraitCollection(userInterfaceLevel: .elevated)).compactAppearance = elevatedAppearance
            UINavigationBar.appearance(for: UITraitCollection(userInterfaceLevel: .elevated)).scrollEdgeAppearance = elevatedAppearance
        } else {
            UINavigationBar.appearance().shadowImage = UIColor.clear.asImage()
            UINavigationBar.appearance().titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.brand(.primaryText()),
                NSAttributedString.Key.font: Fonts.fontFor(style: .headline),
            ]
            UINavigationBar.appearance().largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.brand(.primaryText()),
                NSAttributedString.Key.font: Fonts.fontFor(style: .largeTitle),
            ]
        }

        UINavigationBar.appearance().tintColor = .brand(.primaryTintColor)

        UITabBar.appearance().unselectedItemTintColor = .brand(.secondaryText)
        UITabBar.appearance().tintColor = .brand(.primaryTintColor)

        UITabBarItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: Fonts.fontFor(style: .footnote),
            ],
            for: .normal
        )
        UITabBarItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: Fonts.fontFor(style: .footnote),
            ],
            for: .selected
        )

        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .brand(.primaryTintColor)

        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: Fonts.fontFor(style: .footnote),
            ],
            for: .normal
        )

        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font: Fonts.fontFor(style: .footnote),
            ],
            for: .highlighted
        )

        UIBarButtonItem.appearance().tintColor = .brand(.primaryTintColor)

        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        barButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .highlighted)

        UITabBar.appearance().barTintColor = .brand(.primaryBackground())

        if #available(iOS 13.0, *) {
            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .dark)
            ).backgroundImage = UIColor.brand(.primaryBackground()).resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)).asImage()

            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .light)
            ).backgroundImage = UIColor.brand(.primaryBackground()).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)).asImage()

            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .dark)
            ).shadowImage = UIColor.brand(.primaryBackground()).resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)).asImage()

            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .light)
            ).shadowImage = UIColor.brand(.primaryBackground()).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)).asImage()
        } else {
            UITabBar.appearance().backgroundImage = UIColor.brand(.primaryBackground()).asImage()
            UITabBar.appearance().shadowImage = UIColor.brand(.primaryBorderColor).asImage()
            UINavigationBar.appearance().backIndicatorImage = hCoreUIAssets.backButton.image
            UINavigationBar.appearance().backIndicatorTransitionMaskImage = hCoreUIAssets.backButton.image
        }

        UITabBarItem.appearance().setBadgeTextAttributes([
            NSAttributedString.Key.font: Fonts.fontFor(style: .footnote),
        ], for: .normal)
        UITabBarItem.appearance().setBadgeTextAttributes([
            NSAttributedString.Key.font: Fonts.fontFor(style: .footnote),
        ], for: .selected)

        UIImageView.appearance().tintColor = .brand(.primaryTintColor)

        current = .custom
    }

    static let custom = DefaultStyling(
        text: .brand(.body(color: .primary)),
        field: FieldStyle(
            text: .brand(.body(color: .primary)),
            placeholder: .brand(.body(color: .secondary)),
            disabled: .brand(.body(color: .tertiary)),
            cursorColor: .black
        ),
        detailText: .brand(.callout(color: .primary)),
        titleSubtitle: .init(title: .brand(.headline(color: .primary)), subtitle: .brand(.subHeadline(color: .secondary)), spacing: 0, insets: .zero),
        button: .default,
        barButton: .init(text: .brand(.headline(color: .link))),
        switch: .init(onTintColor: .brand(.primaryButtonBackgroundColor), thumbTintColor: .white, onImage: nil, offImage: nil),
        segmentedControl: .default,
        sectionGrouped: .brandGrouped,
        sectionPlain: .brandPlain,
        formGrouped: .brandGrouped,
        formPlain: .brandPlain,
        sectionBackground: .init(background: .init(color: .brand(.primaryBackground()), border: .none), topSeparator: .none, bottomSeparator: .none),
        sectionBackgroundSelected: .init(background: .init(color: .brand(.primaryButtonBackgroundColor), border: .none), topSeparator: .none, bottomSeparator: .none),
        scrollView: FormScrollView.self,
        plainTableView: ListTableView.self,
        groupedTableView: FormTableView.self,
        collectionView: UICollectionView.self
    )
}

extension DynamicSectionStyle {
    static let brandPlain = DynamicSectionStyle { _ -> SectionStyle in
        fatalError("never use plain style")
    }

    static let brandGrouped = DynamicSectionStyle { trait -> SectionStyle in
        let backgroundColor: UIColor

        if #available(iOS 13.0, *) {
            backgroundColor = trait.userInterfaceLevel == .elevated ? UIColor.brand(.primaryBackground()) : UIColor.brand(.secondaryBackground())
        } else {
            backgroundColor = UIColor.brand(.secondaryBackground())
        }

        return Style(
            rowInsets: .init(inset: 15),
            itemSpacing: 10,
            minRowHeight: 0,
            background: .init(style:
                .init(background: .init(color: backgroundColor, border: .init(width: 0, color: UIColor.clear, cornerRadius: 8, borderEdges: .all)),
                      topSeparator: .init(style: .init(width: 1 / UIScreen.main.scale, color: UIColor.brand(.primaryBorderColor)), insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)),
                      bottomSeparator: .init(style: .init(width: 1 / UIScreen.main.scale, color: UIColor.brand(.primaryBorderColor)), insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)))
            ),
            selectedBackground: .init(all: UIColor.brand(.primaryBackground()).asImage()),
            header: .init(text: .brand(.title3(color: .primary)), insets: UIEdgeInsets(inset: 8)),
            footer: .init(text: .brand(.footnote(color: .tertiary)), insets: UIEdgeInsets(inset: 8))
        )
    }
}

extension DynamicFormStyle {
    static let brandPlain = DynamicFormStyle { _ -> FormStyle in
        .init(insets: UIEdgeInsets(inset: 15))
    }

    static let brandGrouped = DynamicFormStyle { _ -> FormStyle in
        .init(insets: UIEdgeInsets(inset: 15))
    }
}

final class FormScrollView: UIScrollView {}

final class FormTableView: UITableView {
    override func didMoveToWindow() {
        super.didMoveToWindow()
        // fix large titles being collapsed on load
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.navigationController?.navigationBar.sizeToFit()
        }
    }
}

final class ListTableView: UITableView {}
