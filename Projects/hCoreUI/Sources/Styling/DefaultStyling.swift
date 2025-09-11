import Foundation
import StoreKit
import SwiftUI

public class hNavigationBaseController: UINavigationController {
    var onDeinit: (@Sendable () -> Void)?

    deinit {
        self.onDeinit?()
    }
}

public class hNavigationController: hNavigationBaseController {
    private let additionalHeight: CGFloat?

    public init(additionalHeight: CGFloat? = nil) {
        self.additionalHeight = additionalHeight
        super.init(navigationBarClass: NavBar.self, toolbarClass: UIToolbar.self)
        if let navBar = navigationBar as? NavBar {
            navBar.additionalHeight = additionalHeight
        }
        if let additionalHeight {
            additionalSafeAreaInsets.top = additionalHeight
        }
    }

    override public init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        additionalHeight = nil
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }

    @available(*, unavailable)
    required init?(
        coder _: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NavBar: UINavigationBar {
    var additionalHeight: CGFloat?

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        if let additionalHeight {
            return CGSize(width: size.width, height: size.height + additionalHeight)
        } else {
            return super.sizeThatFits(size)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let additionalHeight {
            for subview in subviews {
                let stringFromClass = NSStringFromClass(subview.classForCoder)
                if stringFromClass.contains("UIProgressView") {
                    subview.frame = CGRect(
                        x: subview.frame.origin.x,
                        y: -additionalHeight,
                        width: subview.frame.width,
                        height: subview.frame.height
                    )
                }
                if stringFromClass.contains("BarContent") {
                    subview.frame = CGRect(
                        x: 0,
                        y: additionalHeight,
                        width: frame.width,
                        height: subview.frame.size.height
                    )
                }
            }
        }
        for subview in subviews {
            let stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("BarContent") {
                subview.clipsToBounds = false
                subview.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: frame.width + 4,
                    height: subview.frame.size.height
                )
            }
        }
    }
}

public class hNavigationControllerWithLargerNavBar: hNavigationBaseController {
    public static var navigationBarHeight: CGFloat = 80

    public init() {
        super.init(navigationBarClass: LargeNavBar.self, toolbarClass: UIToolbar.self)
        additionalSafeAreaInsets.top = hNavigationControllerWithLargerNavBar.navigationBarHeight - 56
    }

    @available(*, unavailable)
    required init?(
        coder _: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LargeNavBar: UINavigationBar {
    override func sizeThatFits(_: CGSize) -> CGSize {
        CGSize(
            width: UIScreen.main.bounds.size.width,
            height: hNavigationControllerWithLargerNavBar.navigationBarHeight
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in subviews {
            if subview.frame.size.height != hNavigationControllerWithLargerNavBar.navigationBarHeight {
                let stringFromClass = NSStringFromClass(subview.classForCoder)
                if stringFromClass.contains("BarContent") {
                    subview.frame = CGRect(
                        x: 0,
                        y: -6,
                        width: frame.width,
                        height: hNavigationControllerWithLargerNavBar.navigationBarHeight
                    )
                }
            }
        }
    }
}

@MainActor
public struct DefaultStyling {
    @Environment(\.hWithoutFontMultiplier) var withoutFontMultiplier

    public static func applyCommonNavigationBarStyling(_ appearance: UINavigationBarAppearance) {
        appearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.brand(.primaryText()),
            NSAttributedString.Key.font: Fonts.fontFor(style: .body1),
        ]
        appearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.brand(.primaryText()),
            NSAttributedString.Key.font: Fonts.fontFor(style: .body1, withoutFontMultipler: true),
        ]

        let backImageInsets: UIEdgeInsets = {
            if #available(iOS 26.0, *) {
                UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -4)
            } else {
                UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
            }
        }()

        let backImage = hCoreUIAssets.chevronLeft.image.withAlignmentRectInsets(
            backImageInsets
        )

        appearance.setBackIndicatorImage(
            backImage,
            transitionMaskImage: backImage
        )
        appearance.backButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.clear
        ]
    }

    public static func scrollEdgeNavigationBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        DefaultStyling.applyCommonNavigationBarStyling(appearance)
        appearance.backgroundColor = .clear
        appearance.shadowImage = UIColor.clear.asImage()
        appearance.backgroundImage = nil
        applyCommonNavigationBarStyling(appearance)
        return appearance
    }

    public static func standardNavigationBarAppearance(style: UIUserInterfaceStyle) -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = hBorderColor.primary.colorFor(.light, .base).color.uiColor()
        appearance.backgroundImage = nil
        appearance.backgroundEffect = UIBlurEffect(style: style == .dark ? .dark : .light)
        applyCommonNavigationBarStyling(appearance)

        return appearance
    }

    public static func compactNavigationBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.clear
        appearance.shadowColor = hBorderColor.primary.colorFor(.light, .base).color.uiColor()
        appearance.backgroundEffect = UIBlurEffect(style: .light)
        applyCommonNavigationBarStyling(appearance)

        return appearance
    }

    public static func setNavigationBarAppearance() {
        UINavigationBar.appearance(for: .init(userInterfaceStyle: .dark)).standardAppearance =
            standardNavigationBarAppearance(style: .dark)
        UINavigationBar.appearance(for: .init(userInterfaceStyle: .light)).standardAppearance =
            standardNavigationBarAppearance(style: .light)
        UINavigationBar.appearance().scrollEdgeAppearance = scrollEdgeNavigationBarAppearance()
        UINavigationBar.appearance().compactAppearance = compactNavigationBarAppearance()

        UINavigationBar.appearance(whenContainedInInstancesOf: [hNavigationController.self]).scrollEdgeAppearance =
            scrollEdgeNavigationBarAppearance()

        UINavigationBar.appearance(
            for: .init(userInterfaceStyle: .dark),
            whenContainedInInstancesOf: [hNavigationController.self]
        )
        .standardAppearance =
            standardNavigationBarAppearance(style: .dark)
        UINavigationBar.appearance(
            for: .init(userInterfaceStyle: .light),
            whenContainedInInstancesOf: [hNavigationController.self]
        )
        .standardAppearance =
            standardNavigationBarAppearance(style: .light)
        UINavigationBar.appearance(whenContainedInInstancesOf: [hNavigationController.self]).compactAppearance =
            compactNavigationBarAppearance()
        UINavigationBar.appearance(whenContainedInInstancesOf: [hNavigationControllerWithLargerNavBar.self])
            .scrollEdgeAppearance =
            scrollEdgeNavigationBarAppearance()

        UINavigationBar.appearance(
            for: .init(userInterfaceStyle: .dark),
            whenContainedInInstancesOf: [hNavigationControllerWithLargerNavBar.self]
        )
        .standardAppearance =
            standardNavigationBarAppearance(style: .dark)
        UINavigationBar.appearance(
            for: .init(userInterfaceStyle: .light),
            whenContainedInInstancesOf: [hNavigationControllerWithLargerNavBar.self]
        )
        .standardAppearance =
            standardNavigationBarAppearance(style: .light)
        UINavigationBar.appearance(whenContainedInInstancesOf: [hNavigationControllerWithLargerNavBar.self])
            .compactAppearance =
            compactNavigationBarAppearance()
    }

    public static func installCustom() {
        ListTableView.appearance().backgroundColor = .brand(.primaryBackground())

        UIRefreshControl.appearance().tintColor = .brand(.primaryText())
        setNavigationBarAppearance()
        setTabBarAppearance()
        setSegmentedControllAppearance()

        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .brand(.primaryText())

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [hNavigationController.self])
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.font: Fonts.fontFor(style: .label, withoutFontMultipler: true)
                ],
                for: .normal
            )

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [hNavigationController.self])
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.font: Fonts.fontFor(style: .label, withoutFontMultipler: true)
                ],
                for: .highlighted
            )

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [hNavigationControllerWithLargerNavBar.self])
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.font: Fonts.fontFor(style: .label, withoutFontMultipler: true)
                ],
                for: .normal
            )

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [hNavigationControllerWithLargerNavBar.self])
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.font: Fonts.fontFor(style: .label, withoutFontMultipler: true)
                ],
                for: .highlighted
            )

        UIBarButtonItem.appearance().tintColor = .brand(.primaryText())

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
        barButtonItemAppearance.tintColor = .brand(.primaryText())

        // selection color
        // selected date is this color, system adds bold to it automaticly
        // this color is used as background and system adds some alpha to it
        UIDatePicker.appearance().tintColor = .brand(.datePickerSelectionColor)

        UIImageView.appearance().tintColor = .brand(.primaryText())
        UIImageView.appearance(whenContainedInInstancesOf: [UIDatePicker.self]).tintColor = .brand(
            .primaryText()
        )
        // date picker buttons < and > for switching months
        UIButton.appearance(whenContainedInInstancesOf: [UIDatePicker.self]).tintColor = .brand(.primaryText())
    }

    private static func setTabBarAppearance() {
        func configureAppearance(appearance: UITabBarAppearance, isStandard: Bool, style: UIUserInterfaceStyle) {
            func configureTabBarContent(itemAppearance: UITabBarItemAppearance, style: UIUserInterfaceStyle) {
                func configureBadge(appearance: UITabBarItemStateAppearance) {
                    appearance.badgeBackgroundColor = .clear
                    appearance.badgePositionAdjustment.horizontal = 0
                    appearance.badgePositionAdjustment.vertical = -4
                    appearance.badgeTextAttributes = [
                        NSAttributedString.Key.foregroundColor: UIColor.brand(.alert),
                        NSAttributedString.Key.font: Fonts.fontFor(style: .display1, withoutFontMultipler: true),
                    ]
                }
                configureBadge(appearance: itemAppearance.normal)
                configureBadge(appearance: itemAppearance.selected)
                configureBadge(appearance: itemAppearance.focused)
                configureBadge(appearance: itemAppearance.disabled)

                let selectedColor = hFillColor.Opaque.primary.colorFor(.init(style) ?? .light, .base).color.uiColor()
                let nonSelecetedColor = hFillColor.Translucent.secondary.colorFor(.init(style) ?? .light, .base).color
                    .uiColor()

                let font = Fonts.fontFor(style: .tabBar, withoutFontMultipler: true)

                itemAppearance.normal.iconColor = nonSelecetedColor
                itemAppearance.normal.titleTextAttributes = [
                    .font: font,
                    .foregroundColor: nonSelecetedColor,
                ]

                itemAppearance.selected.iconColor = selectedColor
                itemAppearance.selected.titleTextAttributes = [
                    .font: font,
                    .foregroundColor: selectedColor,
                ]
                itemAppearance.focused.iconColor = selectedColor
                itemAppearance.focused.titleTextAttributes = [
                    .font: font,
                    .foregroundColor: selectedColor,
                ]
                itemAppearance.disabled.iconColor = nonSelecetedColor
                itemAppearance.disabled.titleTextAttributes = [
                    .font: font,
                    .foregroundColor: nonSelecetedColor,
                ]
            }

            if isStandard {
                appearance.configureWithOpaqueBackground()
            }
            appearance.backgroundColor = hBackgroundColor.primary.colorFor(.init(style) ?? .light, .base).color
                .uiColor()
            appearance.shadowImage = hBorderColor.primary.colorFor(.init(style) ?? .light, .base).color.uiColor()
                .asImage()
            let tabBarItemAppearance = UITabBarItemAppearance()
            configureTabBarContent(itemAppearance: tabBarItemAppearance, style: style)
            appearance.stackedLayoutAppearance = tabBarItemAppearance
        }

        let standard = UITabBarAppearance()
        let standardDark = UITabBarAppearance()
        let scrollEdgeAppearance = UITabBarAppearance()
        let scrollEdgeAppearanceDark = UITabBarAppearance()

        configureAppearance(appearance: standard, isStandard: true, style: .light)
        configureAppearance(appearance: standardDark, isStandard: true, style: .dark)
        configureAppearance(appearance: scrollEdgeAppearance, isStandard: false, style: .light)
        configureAppearance(appearance: scrollEdgeAppearanceDark, isStandard: false, style: .dark)

        UITabBar.appearance(for: UITraitCollection(userInterfaceStyle: .light)).standardAppearance = standard
        UITabBar.appearance(for: UITraitCollection(userInterfaceStyle: .dark)).standardAppearance = standardDark
        UITabBar.appearance(for: UITraitCollection(userInterfaceStyle: .light)).scrollEdgeAppearance =
            scrollEdgeAppearance
        UITabBar.appearance(for: UITraitCollection(userInterfaceStyle: .dark)).scrollEdgeAppearance =
            scrollEdgeAppearanceDark
    }

    private static func setSegmentedControllAppearance() {
        let font = Fonts.fontFor(style: .label, withoutFontMultipler: true)

        UISegmentedControl.appearance()
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.foregroundColor: UIColor.brand(.secondaryText),
                    NSAttributedString.Key.font: font,
                ],
                for: .normal
            )

        UISegmentedControl.appearance()
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.foregroundColor: UIColor.brand(.primaryText(false)),
                    NSAttributedString.Key.font: font,
                ],
                for: .selected
            )
    }
}

final class ListTableView: UITableView {}

@MainActor
extension CGFloat {
    public static var cornerRadiusXS: CGFloat = 6
    public static var cornerRadiusS: CGFloat = 8
    public static var cornerRadiusM: CGFloat = 10
    public static var cornerRadiusL: CGFloat = 12
    public static var cornerRadiusXL: CGFloat = 16
    public static var cornerRadiusXXL: CGFloat = 24
}

extension CGFloat {
    public static let padding2: CGFloat = 2
    public static let padding3: CGFloat = 2
    public static let padding4: CGFloat = 4
    public static let padding6: CGFloat = 6
    public static let padding8: CGFloat = 8
    public static let padding10: CGFloat = 10
    public static let padding12: CGFloat = 12
    public static let padding14: CGFloat = 14
    public static let padding16: CGFloat = 16
    public static let padding18: CGFloat = 18
    public static let padding24: CGFloat = 24
    public static let padding32: CGFloat = 32
    public static let padding40: CGFloat = 40
    public static let padding48: CGFloat = 48
    public static let padding56: CGFloat = 56
    public static let padding60: CGFloat = 60
    public static let padding64: CGFloat = 64
    public static let padding72: CGFloat = 72
    public static let padding80: CGFloat = 80
    public static let padding88: CGFloat = 88
    public static let padding96: CGFloat = 96
}
