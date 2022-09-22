import Flow
import Foundation
import Presentation
import UIKit

public enum MenuStyle { case `default`, destructive }

public protocol MenuChildable {}

public struct MenuChildAction: Equatable {
    let identifier: String

    public init(
        identifier: String
    ) {
        self.identifier = identifier
    }
}

public struct MenuChild: MenuChildable {
    let title: String
    let style: MenuStyle
    let image: UIImage?
    let action: MenuChildAction

    public init(
        title: String,
        style: MenuStyle,
        image: UIImage?,
        action: MenuChildAction
    ) {
        self.title = title
        self.style = style
        self.image = image
        self.action = action
    }
}

public struct Menu: MenuChildable {
    let title: String?
    let children: [MenuChildable]

    public init(
        title: String?,
        children: [MenuChildable]
    ) {
        self.title = title
        self.children = children
    }
}

func composeMenu(
    _ menu: Menu,
    viewController: UIViewController,
    onAction: @escaping (_ action: MenuChildAction) -> Void
) -> UIMenu {
    UIMenu(
        title: menu.title ?? "",
        options: [.displayInline],
        children: menu.children.compactMap { menuChild in
            if let menuChild = menuChild as? MenuChild {
                return UIAction(
                    title: menuChild.title,
                    image: menuChild.image,
                    attributes: menuChild.style == .destructive ? .destructive : []
                ) { _ in onAction(menuChild.action) }
            } else if let menu = menuChild as? Menu {
                return composeMenu(menu, viewController: viewController, onAction: onAction)
            }

            return nil
        }
    )
}

func composeAlertActions(
    _ children: [MenuChildable],
    viewController: UIViewController,
    onAction: @escaping (_ action: MenuChildAction) -> Void
) -> [Alert<Void>.Action] {
    children.map { menuChild -> [Alert<Void>.Action] in
        if let menuChild = menuChild as? MenuChild {
            return [
                Alert.Action(
                    title: menuChild.title,
                    style: menuChild.style == .destructive ? .destructive : .default
                ) { _ in onAction(menuChild.action) }
            ]
        } else if let menu = menuChild as? Menu {
            return composeAlertActions(menu.children, viewController: viewController, onAction: onAction)
        }

        return []
    }
    .flatMap { $0 }
}

extension UIBarButtonItem {
    public func attachSinglePressMenu(
        viewController: UIViewController,
        menu: Menu,
        onAction: @escaping (_ action: MenuChildAction) -> Void
    ) -> Disposable {
        let bag = DisposeBag()
        self.menu = composeMenu(menu, viewController: viewController, onAction: onAction)
        return bag
    }
}
