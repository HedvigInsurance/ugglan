import Form
import Foundation
import Presentation
import StoreKit
import SwiftUI

public class hNavigationBaseController: UINavigationController {
    var onDeinit: (() -> Void)?

    deinit {
        onDeinit?()
    }
}

public class hNavigationController: hNavigationBaseController {
    private let additionalHeight: CGFloat?

    public init(additionalHeight: CGFloat? = nil) {
        self.additionalHeight = additionalHeight
        super.init(navigationBarClass: NavBar.self, toolbarClass: UIToolbar.self)
        if let navBar = self.navigationBar as? NavBar {
            navBar.additionalHeight = additionalHeight
        }
        if let additionalHeight {
            additionalSafeAreaInsets.top = additionalHeight
        }
    }

    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        self.additionalHeight = nil
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }

    required init?(
        coder aDecoder: NSCoder
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
            subviews.forEach { (subview) in
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
                        width: self.frame.width,
                        height: subview.frame.size.height
                    )
                }
            }
        }
        subviews.forEach { (subview) in
            let stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("BarContent") {
                subview.clipsToBounds = false
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

    required init?(
        coder aDecoder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LargeNavBar: UINavigationBar {

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(
            width: UIScreen.main.bounds.size.width,
            height: hNavigationControllerWithLargerNavBar.navigationBarHeight
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.forEach { (subview) in
            if subview.frame.size.height != hNavigationControllerWithLargerNavBar.navigationBarHeight {
                let stringFromClass = NSStringFromClass(subview.classForCoder)
                if stringFromClass.contains("BarContent") {
                    subview.frame = CGRect(
                        x: 0,
                        y: -6,
                        width: self.frame.width,
                        height: hNavigationControllerWithLargerNavBar.navigationBarHeight
                    )
                }
            }
        }
    }
}

extension BarButtonStyle {
    public static var destructive = BarButtonStyle(text: UIColor.brandStyle(.caution))
}

extension DefaultStyling {
    public static let tabBarBackgroundColor = UIColor.brand(.primaryBackground())

    public static let navigationBarBackgroundColor = UIColor(dynamic: { trait -> UIColor in
        return .brand(.primaryBackground())
    })

    public static func applyCommonNavigationBarStyling(_ appearance: UINavigationBarAppearance) {
        appearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.brand(.primaryText()),
            NSAttributedString.Key.font: Fonts.fontFor(style: .body1),
        ]
        appearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.brand(.primaryText()),
            NSAttributedString.Key.font: Fonts.fontFor(style: .body1),
        ]

        let backImage = hCoreUIAssets.chevronLeft.image.withAlignmentRectInsets(
            UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
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
        customNavigationController = { options in
            if options.contains(.preffersLargerNavigationBar) {
                return hNavigationControllerWithLargerNavBar()
            } else {
                let additionalHeight: CGFloat? = {
                    if options.contains(.withAdditionalSpaceForProgressBar) {
                        return 4
                    }
                    return nil
                }()
                return hNavigationController(additionalHeight: additionalHeight)
            }
        }

        ListTableView.appearance().backgroundColor = .brand(.primaryBackground())

        UIRefreshControl.appearance().tintColor = .brand(.primaryText())
        setNavigationBarAppearance()
        setTabBarAppearance()
        setSegmentedControllAppearance()

        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .brand(.primaryText())

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [hNavigationController.self])
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.font: Fonts.fontFor(style: .label)
                ],
                for: .normal
            )

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [hNavigationController.self])
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.font: Fonts.fontFor(style: .label)
                ],
                for: .highlighted
            )

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [hNavigationControllerWithLargerNavBar.self])
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.font: Fonts.fontFor(style: .label)
                ],
                for: .normal
            )

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [hNavigationControllerWithLargerNavBar.self])
            .setTitleTextAttributes(
                [
                    NSAttributedString.Key.font: Fonts.fontFor(style: .label)
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

        //selection color
        //selected date is this color, system adds bold to it automaticly
        //this color is used as background and system adds some alpha to it
        UIDatePicker.appearance().tintColor = .brand(.datePickerSelectionColor)

        UIImageView.appearance().tintColor = .brand(.primaryText())
        UIImageView.appearance(whenContainedInInstancesOf: [UIDatePicker.self]).tintColor = .brand(
            .primaryText()
        )
        //date picker buttons < and > for switching months
        UIButton.appearance(whenContainedInInstancesOf: [UIDatePicker.self]).tintColor = .brand(.primaryText())
        current = .custom

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
                        NSAttributedString.Key.font: Fonts.fontFor(style: .display1),
                    ]
                }
                configureBadge(appearance: itemAppearance.normal)
                configureBadge(appearance: itemAppearance.selected)
                configureBadge(appearance: itemAppearance.focused)
                configureBadge(appearance: itemAppearance.disabled)

                let selectedColor = hFillColor.Opaque.primary.colorFor(.init(style) ?? .light, .base).color.uiColor()
                let nonSelecetedColor = hFillColor.Translucent.secondary.colorFor(.init(style) ?? .light, .base).color
                    .uiColor()
                itemAppearance.normal.iconColor = nonSelecetedColor
                itemAppearance.normal.titleTextAttributes = [
                    .font: Fonts.fontFor(style: .finePrint),
                    .foregroundColor: nonSelecetedColor,
                ]
                itemAppearance.selected.iconColor = selectedColor
                itemAppearance.selected.titleTextAttributes = [
                    .font: Fonts.fontFor(style: .finePrint),
                    .foregroundColor: selectedColor,
                ]
                itemAppearance.focused.iconColor = selectedColor
                itemAppearance.focused.titleTextAttributes = [
                    .font: Fonts.fontFor(style: .finePrint),
                    .foregroundColor: selectedColor,
                ]
                itemAppearance.disabled.iconColor = nonSelecetedColor
                itemAppearance.disabled.titleTextAttributes = [
                    .font: Fonts.fontFor(style: .finePrint),
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
        let font = Fonts.fontFor(style: .label)

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

    public static let custom = DefaultStyling(
        text: UIColor.brandStyle(.primaryText()),
        field: FieldStyle(
            text: UIColor.brandStyle(.primaryText()),
            placeholder: UIColor.brandStyle(.secondaryText),
            disabled: UIColor.brandStyle(.secondaryText),
            cursorColor: .brand(.primaryText())
        ),
        detailText: UIColor.brandStyle(.primaryText()).centerAligned,
        titleSubtitle: .init(
            title: UIColor.brandStyle(.primaryText()),
            subtitle: UIColor.brandStyle(.secondaryText),
            spacing: 0,
            insets: .zero
        ),
        button: .default,
        barButton: .init(text: UIColor.brandStyle(.primaryText())),
        switch: .init(
            onTintColor: .brand(.primaryBackground(true)),
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
            background: .init(color: .brand(.primaryBackground(true)), border: .none),
            topSeparator: .none,
            bottomSeparator: .none
        ),
        sectionBackgroundSelected: .init(
            background: .init(color: .brand(.primaryBackground(true)), border: .none),
            topSeparator: .none,
            bottomSeparator: .none
        ),
        scrollView: UIScrollView.self,
        plainTableView: ListTableView.self,
        groupedTableView: UITableView.self,
        insetGroupedTableView: UITableView.self,
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
                header: .init(text: UIColor.brandStyle(.primaryText()), insets: headerAndFooterInset),
                footer: .init(
                    text: UIColor.brandStyle(.secondaryText),
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
        roundedCornerRadius: CGFloat = .cornerRadiusL,
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
                header: .init(text: UIColor.brandStyle(.primaryText()), insets: UIEdgeInsets(inset: 15)),
                footer: .init(
                    text: UIColor.brandStyle(.secondaryText),
                    insets: UIEdgeInsets(inset: 15)
                )
            )
        }
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
            header: .init(text: UIColor.brandStyle(.primaryText()), insets: UIEdgeInsets(inset: 8)),
            footer: .init(text: UIColor.brandStyle(.secondaryText), insets: UIEdgeInsets(inset: 8))
        )
    }
}

extension DynamicFormStyle {
    static let brandPlain = DynamicFormStyle { trait in
        if trait.userInterfaceIdiom == .pad && trait.horizontalSizeClass == .regular {
            return .init(insets: UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40))
        }

        if trait.verticalSizeClass == .compact {
            return .init(insets: UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0))
        }

        return .init(insets: .zero)
    }

    static let brandGrouped = DynamicFormStyle { trait in
        if trait.userInterfaceIdiom == .pad && trait.horizontalSizeClass == .regular {
            return .init(insets: UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40))
        }

        if trait.verticalSizeClass == .compact {
            return .init(insets: UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0))
        }

        return .init(insets: .zero)
    }

    public static let brandInset = DynamicFormStyle { trait in
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
    public static var cornerRadiusXS: CGFloat = 6
    public static var cornerRadiusS: CGFloat = 8
    public static var cornerRadiusM: CGFloat = 10
    public static var cornerRadiusL: CGFloat = 12
    public static var cornerRadiusXL: CGFloat = 16
    public static var cornerRadiusXXL: CGFloat = 24

}

extension CGFloat {
    public static var padding4: CGFloat = 4
    public static var padding6: CGFloat = 6
    public static var padding8: CGFloat = 8
    public static var padding10: CGFloat = 10
    public static var padding12: CGFloat = 12
    public static var padding16: CGFloat = 16
    public static var padding24: CGFloat = 24
    public static var padding32: CGFloat = 32
    public static var padding40: CGFloat = 40
    public static var padding48: CGFloat = 48
    public static var padding56: CGFloat = 56
    public static var padding64: CGFloat = 64
    public static var padding72: CGFloat = 72
    public static var padding80: CGFloat = 80
    public static var padding88: CGFloat = 88
    public static var padding96: CGFloat = 96
}
