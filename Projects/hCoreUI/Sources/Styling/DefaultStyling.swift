import Flow
import Form
import Foundation
import Presentation
import StoreKit
import UIKit

public class hNavigationController: UINavigationController {
    public init() {
        super.init(navigationBarClass: UINavigationBar.self, toolbarClass: UIToolbar.self)
    }

    required init?(
        coder aDecoder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BarButtonStyle {
    public static var destructive = BarButtonStyle(text: .brand(.headline(color: .destructive)))
}

extension DefaultStyling {
    public static let tabBarBackgroundColor = UIColor(dynamic: { trait -> UIColor in
        if trait.userInterfaceStyle == .dark {
            return UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.00)
        }

        return UIColor.white
    })

    public static let navigationBarBackgroundColor = UIColor(dynamic: { trait -> UIColor in
        return .brand(.primaryBackground())
    })

    @available(iOS 13, *)
    public static func applyCommonNavigationBarStyling(_ appearance: UINavigationBarAppearance) {
        appearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.brand(.primaryText()),
            NSAttributedString.Key.font: Fonts.fontFor(style: .headline),
        ]
        appearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.brand(.primaryText()),
            NSAttributedString.Key.font: Fonts.fontFor(style: .largeTitle),
        ]

        appearance.setBackIndicatorImage(
            hCoreUIAssets.backButton.image,
            transitionMaskImage: hCoreUIAssets.backButton.image
        )
        appearance.backButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.clear
        ]
    }

    public static func scrollEdgeNavigationBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowImage = UIColor.clear.asImage()

        applyCommonNavigationBarStyling(appearance)

        return appearance
    }

    public static func standardNavigationBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = navigationBarBackgroundColor
        appearance.shadowImage = UIColor.clear.asImage()

        applyCommonNavigationBarStyling(appearance)

        return appearance
    }

    public static func compactNavigationBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = navigationBarBackgroundColor
        appearance.shadowImage = UIColor.clear.asImage()

        applyCommonNavigationBarStyling(appearance)

        return appearance
    }

    public static func setNavigationBarAppearance() {
        UINavigationBar.appearance(whenContainedInInstancesOf: [hNavigationController.self]).scrollEdgeAppearance =
            scrollEdgeNavigationBarAppearance()
        UINavigationBar.appearance(whenContainedInInstancesOf: [hNavigationController.self]).standardAppearance =
            standardNavigationBarAppearance()
        UINavigationBar.appearance(whenContainedInInstancesOf: [hNavigationController.self]).compactAppearance =
            compactNavigationBarAppearance()
    }

    public static func installCustom() {
        customNavigationController = { _ in hNavigationController() }

        ListTableView.appearance().backgroundColor = .brand(.primaryBackground())

        for view in [FormScrollView.self, FormTableView.self] {
            view.appearance(
                for: UITraitCollection(userInterfaceIdiom: .pad)
            )
            .backgroundColor = .brand(.primaryBackground())
            view.appearance().backgroundColor = .brand(.primaryBackground())

            if #available(iOS 13.0, *) {
                view.appearance(for: UITraitCollection(userInterfaceLevel: .elevated)).backgroundColor =
                    .brand(.secondaryBackground())
            }
        }

        UIRefreshControl.appearance().tintColor = .brand(.primaryTintColor)

        if #available(iOS 13.0, *) {
            setNavigationBarAppearance()
        } else {
            UINavigationBar.appearance(whenContainedInInstancesOf: [hNavigationController.self]).shadowImage = UIColor
                .clear
                .asImage()
            UINavigationBar.appearance(whenContainedInInstancesOf: [hNavigationController.self]).titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.brand(.primaryText()),
                NSAttributedString.Key.font: Fonts.fontFor(style: .headline),
            ]
            UINavigationBar.appearance(whenContainedInInstancesOf: [hNavigationController.self])
                .largeTitleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.brand(.primaryText()),
                    NSAttributedString.Key.font: Fonts.fontFor(style: .largeTitle),
                ]
        }

        UITabBar.appearance().backgroundColor = tabBarBackgroundColor
        UITabBar.appearance().unselectedItemTintColor = UIColor.brand(.primaryText()).withAlphaComponent(0.4)
        UITabBar.appearance().tintColor = .brand(.primaryText())

        if #available(iOS 13.0, *) {
            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .dark)
            )
            .backgroundImage =
                tabBarBackgroundColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                .asImage()

            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .light)
            )
            .backgroundImage =
                tabBarBackgroundColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                .asImage()

            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .dark)
            )
            .shadowImage = UIColor.brand(.primaryBorderColor)
                .resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)).asImage()

            UITabBar.appearance(
                for: UITraitCollection(userInterfaceStyle: .light)
            )
            .shadowImage = UIColor.brand(.primaryBorderColor)
                .resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)).asImage()
        } else {
            UITabBar.appearance().backgroundImage = tabBarBackgroundColor.asImage()
            UITabBar.appearance().shadowImage = UIColor.brand(.primaryBorderColor).asImage()
        }

        UITabBarItem.appearance()
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.font: Fonts.fontFor(style: .footnote)
                ],
                for: .normal
            )
        UITabBarItem.appearance()
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.font: Fonts.fontFor(style: .footnote)
                ],
                for: .selected
            )

        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .brand(
            .primaryTintColor
        )

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [hNavigationController.self])
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.font: Fonts.fontFor(style: .footnote)
                ],
                for: .normal
            )

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [hNavigationController.self])
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.font: Fonts.fontFor(style: .footnote)
                ],
                for: .highlighted
            )

        UIBarButtonItem.appearance().tintColor = .brand(.primaryTintColor)

        let barButtonItemAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [
            hNavigationController.self
        ])

        barButtonItemAppearance.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.clear],
            for: .normal
        )
        barButtonItemAppearance.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.clear],
            for: .highlighted
        )

        UIImageView.appearance().tintColor = .brand(.primaryTintColor)

        current = .custom
    }

    public static let custom = DefaultStyling(
        text: .brand(.body(color: .primary)),
        field: FieldStyle(
            text: .brand(.body(color: .primary)),
            placeholder: .brand(.body(color: .secondary)),
            disabled: .brand(.body(color: .tertiary)),
            cursorColor: .brand(.primaryText())
        ),
        detailText: TextStyle.brand(.largeTitle(color: .primary)).centerAligned,
        titleSubtitle: .init(
            title: .brand(.headline(color: .primary)),
            subtitle: .brand(.subHeadline(color: .secondary)),
            spacing: 0,
            insets: .zero
        ),
        button: .default,
        barButton: .init(text: .brand(.headline(color: .link))),
        switch: .init(
            onTintColor: .brand(.primaryButtonBackgroundColor),
            thumbTintColor: .white,
            onImage: nil,
            offImage: nil
        ),
        segmentedControl: .default,
        sectionGrouped: .brandGrouped(separatorType: .standard),
        sectionPlain: .brandPlain,
        formGrouped: .brandGrouped,
        formPlain: .brandPlain,
        sectionBackground: .init(
            background: .init(color: .brand(.primaryBackground()), border: .none),
            topSeparator: .none,
            bottomSeparator: .none
        ),
        sectionBackgroundSelected: .init(
            background: .init(color: .brand(.primaryButtonBackgroundColor), border: .none),
            topSeparator: .none,
            bottomSeparator: .none
        ),
        scrollView: FormScrollView.self,
        plainTableView: ListTableView.self,
        groupedTableView: FormTableView.self,
        insetGroupedTableView: FormTableView.self,
        collectionView: UICollectionView.self
    )
}

extension DynamicSectionStyle {
    internal static let brandPlain = DynamicSectionStyle { _ -> SectionStyle in
        fatalError("never use plain style")
    }

    public enum SeparatorType {
        case largeIcons, standard, none
        case custom(_ left: CGFloat)

        var color: UIColor {
            switch self {
            case .largeIcons, .standard, .custom:
                return UIColor.brand(.primaryBorderColor)
            case .none:
                return UIColor.clear
            }
        }

        var left: CGFloat {
            switch self {
            case .largeIcons:
                return 75
            case .standard:
                return 15
            case .none:
                return 0
            case let .custom(left):
                return left
            }
        }
    }

    public static func brandGroupedInset(
        separatorType: SeparatorType,
        border: BorderStyle = .init(
            width: 0,
            color: UIColor.clear,
            cornerRadius: 8,
            borderEdges: .all
        ),
        appliesShadow: Bool = true
    ) -> DynamicSectionStyle {
        DynamicSectionStyle { _ -> SectionStyle in
            let selectedBackgroundColor = UIColor.brand(.primaryBackground(true)).withAlphaComponent(0.1)
            let headerAndFooterInset = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)

            return Style(
                insets: UIEdgeInsets(horizontalInset: 14, verticalInset: 0),
                rowInsets: .init(inset: 15),
                itemSpacing: 10,
                minRowHeight: 0,
                background: .init(
                    style:
                        .init(
                            background: .init(
                                color: .brand(.secondaryBackground()),
                                border: border
                            ),
                            topSeparator: .init(
                                style: .init(
                                    width: 1 / UIScreen.main.scale,
                                    color: separatorType.color
                                ),
                                insets: UIEdgeInsets(
                                    top: 0,
                                    left: separatorType.left,
                                    bottom: 0,
                                    right: 0
                                )
                            ),
                            bottomSeparator: .init(
                                style: .init(
                                    width: 1 / UIScreen.main.scale,
                                    color: separatorType.color
                                ),
                                insets: UIEdgeInsets(
                                    top: 0,
                                    left: separatorType.left,
                                    bottom: 0,
                                    right: 0
                                )
                            )
                        )
                ),
                selectedBackground: .init(
                    style:
                        .init(
                            background: .init(
                                color: selectedBackgroundColor,
                                border: border
                            ),
                            topSeparator: .init(
                                style: .init(
                                    width: 1 / UIScreen.main.scale,
                                    color: separatorType.color
                                ),
                                insets: UIEdgeInsets(
                                    top: 0,
                                    left: separatorType.left,
                                    bottom: 0,
                                    right: 0
                                )
                            ),
                            bottomSeparator: .init(
                                style: .init(
                                    width: 1 / UIScreen.main.scale,
                                    color: separatorType.color
                                ),
                                insets: UIEdgeInsets(
                                    top: 0,
                                    left: separatorType.left,
                                    bottom: 0,
                                    right: 0
                                )
                            )
                        )
                ),
                shadow: .init(
                    opacity: appliesShadow ? 1 : 0,
                    color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.1),
                    offset: CGSize(width: 0, height: 1),
                    blurRadius: 2
                ),
                header: .init(text: .brand(.title3(color: .primary)), insets: headerAndFooterInset),
                footer: .init(
                    text: .brand(.footnote(color: .tertiary)),
                    insets: headerAndFooterInset
                )
            )
        }
    }

    public static func brandGrouped(
        insets: UIEdgeInsets = .zero,
        separatorType: SeparatorType,
        borderColor: UIColor = .clear,
        backgroundColor: UIColor = .clear,
        roundedCornerRadius: CGFloat = .defaultCornerRadius,
        shouldRoundCorners: @escaping (_ traitCollection: UITraitCollection) -> Bool = { trait in
            trait.userInterfaceIdiom == .pad && trait.horizontalSizeClass == .regular
        }
    ) -> DynamicSectionStyle {
        DynamicSectionStyle { trait -> SectionStyle in
            let selectedBackgroundColor = UIColor.brand(.primaryBackground(true)).withAlphaComponent(0.1)

            return Style(
                insets: insets,
                rowInsets: .init(inset: 15),
                itemSpacing: 10,
                minRowHeight: 0,
                background: .init(
                    style:
                        .init(
                            background: .init(
                                color: backgroundColor,
                                border: .init(
                                    width: 1 / UIScreen.main.scale,
                                    color: borderColor,
                                    cornerRadius: shouldRoundCorners(trait)
                                        ? roundedCornerRadius : 0,
                                    borderEdges: .all
                                )
                            ),
                            topSeparator: .init(
                                style: .init(
                                    width: 1 / UIScreen.main.scale,
                                    color: separatorType.color
                                ),
                                insets: UIEdgeInsets(
                                    top: 0,
                                    left: separatorType.left,
                                    bottom: 0,
                                    right: 0
                                )
                            ),
                            bottomSeparator: .init(
                                style: .init(
                                    width: 1 / UIScreen.main.scale,
                                    color: separatorType.color
                                ),
                                insets: UIEdgeInsets(
                                    top: 0,
                                    left: separatorType.left,
                                    bottom: 0,
                                    right: 0
                                )
                            )
                        )
                ),
                selectedBackground: .init(
                    style:
                        .init(
                            background: .init(
                                color: selectedBackgroundColor,
                                border: .init(
                                    width: 1 / UIScreen.main.scale,
                                    color: borderColor,
                                    cornerRadius: shouldRoundCorners(trait)
                                        ? roundedCornerRadius : 0,
                                    borderEdges: .all
                                )
                            ),
                            topSeparator: .init(
                                style: .init(
                                    width: 1 / UIScreen.main.scale,
                                    color: separatorType.color
                                ),
                                insets: UIEdgeInsets(
                                    top: 0,
                                    left: separatorType.left,
                                    bottom: 0,
                                    right: 0
                                )
                            ),
                            bottomSeparator: .init(
                                style: .init(
                                    width: 1 / UIScreen.main.scale,
                                    color: separatorType.color
                                ),
                                insets: UIEdgeInsets(
                                    top: 0,
                                    left: separatorType.left,
                                    bottom: 0,
                                    right: 0
                                )
                            )
                        )
                ),
                shadow: .none,
                header: .init(text: .brand(.title3(color: .primary)), insets: UIEdgeInsets(inset: 15)),
                footer: .init(
                    text: .brand(.footnote(color: .tertiary)),
                    insets: UIEdgeInsets(inset: 15)
                )
            )
        }
    }

    public static let brandGroupedCaution = DynamicSectionStyle { trait -> SectionStyle in
        let backgroundColor = UIColor.tint(.yellowTwo)
        let cornerRadius =
            trait.userInterfaceIdiom == .pad && trait.horizontalSizeClass == .regular
            ? CGFloat.defaultCornerRadius : 0

        return Style(
            insets: .zero,
            rowInsets: .init(inset: 15),
            itemSpacing: 10,
            minRowHeight: 0,
            background: .init(
                style:
                    .init(
                        background: .init(
                            color: backgroundColor,
                            border: .init(
                                width: 1,
                                color: .clear,
                                cornerRadius: cornerRadius,
                                borderEdges: .all
                            )
                        ),
                        topSeparator: .init(
                            style: .init(
                                width: .hairlineWidth,
                                color: UIColor.brand(.primaryBorderColor)
                            ),
                            insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
                        ),
                        bottomSeparator: .init(
                            style: .init(
                                width: .hairlineWidth,
                                color: UIColor.brand(.primaryBorderColor)
                            ),
                            insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
                        )
                    )
            ),
            selectedBackground: .init(
                style:
                    .init(
                        background: .init(
                            color: UIColor.tint(.yellowOne),
                            border: .init(
                                width: 1,
                                color: .clear,
                                cornerRadius: cornerRadius,
                                borderEdges: .all
                            )
                        ),
                        topSeparator: .init(
                            style: .init(
                                width: .hairlineWidth,
                                color: UIColor.brand(.primaryBorderColor)
                            ),
                            insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
                        ),
                        bottomSeparator: .init(
                            style: .init(
                                width: .hairlineWidth,
                                color: UIColor.brand(.primaryBorderColor)
                            ),
                            insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
                        )
                    )
            ),
            shadow: .none,
            header: .init(text: .brand(.title3(color: .primary)), insets: UIEdgeInsets(inset: 8)),
            footer: .init(text: .brand(.footnote(color: .tertiary)), insets: UIEdgeInsets(inset: 8))
        )
    }

    public static let brandGroupedNoBackground = DynamicSectionStyle { _ -> SectionStyle in
        Style(
            insets: .zero,
            rowInsets: .init(inset: 15),
            itemSpacing: 10,
            minRowHeight: 0,
            background: .none,
            selectedBackground: .none,
            shadow: .none,
            header: .init(text: .brand(.title3(color: .primary)), insets: UIEdgeInsets(inset: 8)),
            footer: .init(text: .brand(.footnote(color: .tertiary)), insets: UIEdgeInsets(inset: 8))
        )
    }
}

extension DynamicFormStyle {
    static let brandPlain = DynamicFormStyle { trait -> FormStyle in
        if trait.userInterfaceIdiom == .pad && trait.horizontalSizeClass == .regular {
            return .init(insets: UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40))
        }

        if trait.verticalSizeClass == .compact {
            return .init(insets: UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0))
        }

        return .init(insets: .zero)
    }

    static let brandGrouped = DynamicFormStyle { trait -> FormStyle in
        if trait.userInterfaceIdiom == .pad && trait.horizontalSizeClass == .regular {
            return .init(insets: UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40))
        }

        if trait.verticalSizeClass == .compact {
            return .init(insets: UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0))
        }

        return .init(insets: .zero)
    }

    public static let brandInset = DynamicFormStyle { trait -> FormStyle in
        if trait.userInterfaceIdiom == .pad && trait.horizontalSizeClass == .regular {
            return .init(insets: UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40))
        }

        if trait.verticalSizeClass == .compact {
            return .init(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        }

        return FormStyle(insets: UIEdgeInsets(horizontalInset: 15, verticalInset: 0))
    }
}

extension DynamicTableViewFormStyle {
    public static let brandInset = DynamicTableViewFormStyle(section: .default, form: .brandInset)
}

final class ListTableView: UITableView {}

extension CGFloat {
    public static var smallCornerRadius: CGFloat = 4
    public static var defaultCornerRadius: CGFloat = 8
    public static var smallIconWidth: CGFloat = 16
}
