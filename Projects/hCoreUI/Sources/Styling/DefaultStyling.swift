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
import Flow

public extension BarButtonStyle {
    static var destructive = BarButtonStyle(text: .brand(.headline(color: .destructive)))
}

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

        if #available(iOS 13.0, *) {
            func scrollEdgeAppearance() -> UINavigationBarAppearance {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
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
                    .foregroundColor: UIColor.clear,
                ]
                
                return appearance
            }
            
            func standardAppearance() -> UINavigationBarAppearance {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithDefaultBackground()
                appearance.shadowImage = UIColor.brand(.primaryBorderColor).asImage()
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
                    .foregroundColor: UIColor.clear,
                ]
                
                return appearance
            }
            
            func compactAppearance() -> UINavigationBarAppearance {
                let appearance = UINavigationBarAppearance()
                appearance.backgroundColor = UIColor.white
                appearance.shadowImage = UIColor.brand(.primaryBorderColor).asImage()
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
                    .foregroundColor: UIColor.clear,
                ]
                
                return appearance
            }
            
            UINavigationBar.appearance().standardAppearance = standardAppearance()
            UINavigationBar.appearance().compactAppearance = compactAppearance()
            UINavigationBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance()
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
        
        let tabBarBackgroundColor = UIColor(dynamic: { trait -> UIColor in
            if trait.userInterfaceStyle == .dark {
                return UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.00)
            }
            
            return UIColor.white
        })

        UITabBar.appearance().backgroundColor = tabBarBackgroundColor
        UITabBar.appearance().unselectedItemTintColor = UIColor.brand(.primaryText()).withAlphaComponent(0.4)
        UITabBar.appearance().tintColor = .brand(.primaryText())
        
        if #available(iOS 13.0, *) {
          UITabBar.appearance(
              for: UITraitCollection(userInterfaceStyle: .dark)
          ).backgroundImage = tabBarBackgroundColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)).asImage()

          UITabBar.appearance(
              for: UITraitCollection(userInterfaceStyle: .light)
          ).backgroundImage = tabBarBackgroundColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)).asImage()

          UITabBar.appearance(
              for: UITraitCollection(userInterfaceStyle: .dark)
          ).shadowImage = UIColor.brand(.primaryBorderColor).resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)).asImage()

          UITabBar.appearance(
              for: UITraitCollection(userInterfaceStyle: .light)
          ).shadowImage = UIColor.brand(.primaryBorderColor).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)).asImage()
      } else {
          UITabBar.appearance().backgroundImage = tabBarBackgroundColor.asImage()
          UITabBar.appearance().shadowImage = UIColor.brand(.primaryBorderColor).asImage()
      }

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

        UIImageView.appearance().tintColor = .brand(.primaryTintColor)

        current = .custom
    }

    static let custom = DefaultStyling(
        text: .brand(.body(color: .primary)),
        field: FieldStyle(
            text: .brand(.body(color: .primary)),
            placeholder: .brand(.body(color: .secondary)),
            disabled: .brand(.body(color: .tertiary)),
            cursorColor: .brand(.primaryText())
        ),
        detailText: TextStyle.brand(.largeTitle(color: .primary)).centerAligned,
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
        let selectedBackgroundColor: UIColor = .brand(.primaryBorderColor)

        return Style(
            rowInsets: .init(inset: 15),
            itemSpacing: 10,
            minRowHeight: 0,
            background: .init(style:
                .init(
                    background: .init(
                        color: .clear,
                        border: .init(
                            width: 0,
                            color: UIColor.clear,
                            cornerRadius: 0,
                            borderEdges: .all
                        )
                    ),
                    topSeparator: .init(
                        style: .init(
                            width: 1 / UIScreen.main.scale,
                            color: UIColor.brand(.primaryBorderColor)
                        ),
                        insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
                    ),
                    bottomSeparator: .init(
                        style: .init(
                            width: 1 / UIScreen.main.scale,
                            color: UIColor.brand(.primaryBorderColor)
                        ),
                        insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
                    )
                )
            ),
            selectedBackground: .init(style:
                .init(
                    background: .init(
                        color: selectedBackgroundColor,
                        border: .init(
                            width: 0,
                            color: UIColor.clear,
                            cornerRadius: 0,
                            borderEdges: .all
                        )
                    ),
                    topSeparator: .init(
                        style: .init(
                            width: 1 / UIScreen.main.scale,
                            color: UIColor.brand(.primaryBorderColor)
                        ),
                        insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
                    ),
                    bottomSeparator: .init(
                        style: .init(
                            width: 1 / UIScreen.main.scale,
                            color: UIColor.brand(.primaryBorderColor)
                        ),
                        insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
                    )
                )
            ),
            header: .init(text: .brand(.title3(color: .primary)), insets: UIEdgeInsets(inset: 15)),
            footer: .init(text: .brand(.footnote(color: .tertiary)), insets: UIEdgeInsets(inset: 15))
        )
    }

    public static let brandGroupedCaution = DynamicSectionStyle { trait -> SectionStyle in
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
                .init(background: .init(color: backgroundColor, border: .init(width: 1, color: UIColor.brand(.regularCaution), cornerRadius: 8, borderEdges: .all)),
                      topSeparator: .init(style: .init(width: .hairlineWidth, color: UIColor.brand(.primaryBorderColor)), insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)),
                      bottomSeparator: .init(style: .init(width: .hairlineWidth, color: UIColor.brand(.primaryBorderColor)), insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)))
            ),
            selectedBackground: .init(style:
                .init(background: .init(color: UIColor.brand(.primaryBorderColor).withAlphaComponent(0.2), border: .init(width: 1, color: UIColor.brand(.regularCaution), cornerRadius: 0, borderEdges: .all)),
                      topSeparator: .init(style: .init(width: .hairlineWidth, color: UIColor.brand(.primaryBorderColor)), insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)),
                      bottomSeparator: .init(style: .init(width: .hairlineWidth, color: UIColor.brand(.primaryBorderColor)), insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)))
            ),
            header: .init(text: .brand(.title3(color: .primary)), insets: UIEdgeInsets(inset: 8)),
            footer: .init(text: .brand(.footnote(color: .tertiary)), insets: UIEdgeInsets(inset: 8))
        )
    }

    public static let brandGroupedNoBackground = DynamicSectionStyle { _ -> SectionStyle in
        Style(
            rowInsets: .init(inset: 15),
            itemSpacing: 10,
            minRowHeight: 0,
            background: .none,
            selectedBackground: .none,
            header: .init(text: .brand(.title3(color: .primary)), insets: UIEdgeInsets(inset: 8)),
            footer: .init(text: .brand(.footnote(color: .tertiary)), insets: UIEdgeInsets(inset: 8))
        )
    }
}

extension DynamicFormStyle {
    static let brandPlain = DynamicFormStyle { _ -> FormStyle in
        .init(insets: UIEdgeInsets(inset: 0))
    }

    static let brandGrouped = DynamicFormStyle { _ -> FormStyle in
        .init(insets: UIEdgeInsets(inset: 0))
    }
}

final class ListTableView: UITableView {}
