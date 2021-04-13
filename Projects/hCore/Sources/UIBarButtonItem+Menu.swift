import Flow
import Foundation
import Presentation
import UIKit

public enum MenuStyle {
    case `default`, destructive
}

public protocol MenuChildable {}

public struct MenuChild: MenuChildable {
    let title: String
    let style: MenuStyle
    let image: UIImage?
    let handler: () -> Void

    public init(
        title: String,
        style: MenuStyle,
        image: UIImage?,
        handler: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.image = image
        self.handler = handler
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

@available(iOS 14, *)
func composeMenu(_ menu: Menu) -> UIMenu {
    return UIMenu(
        title: menu.title ?? "",
        options: [.displayInline],
        children: menu.children.compactMap { menuChild in
            if let menuChild = menuChild as? MenuChild {
                return UIAction(
                    title: menuChild.title,
                    image: menuChild.image,
                    attributes: menuChild.style == .destructive ? .destructive : []
                ) { _ in
                    menuChild.handler()
                }
            } else if let menu = menuChild as? Menu {
                return composeMenu(menu)
            }
            
            return nil
        }
    )
}

func composeAlertActions(_ children: [MenuChildable]) -> [Alert<Void>.Action] {
    return children.map { menuChild -> [Alert<Void>.Action] in
        if let menuChild = menuChild as? MenuChild {
            return [
                Alert.Action(
                    title: menuChild.title,
                    style: menuChild.style == .destructive ? .destructive : .default
                ) { _ in
                    menuChild.handler()
                }
            ]
        } else if let menu = menuChild as? Menu {
            return composeAlertActions(menu.children)
        }
        
        return []
    }.flatMap { $0 }
}

public extension UIBarButtonItem {
    func attachSinglePressMenu(viewController: UIViewController, menu: Menu) -> Disposable {
        let bag = DisposeBag()

        if #available(iOS 14, *) {
            self.menu = composeMenu(menu)
        } else {
            bag += onValue {
                let alert = Alert<Void>(
                    title: menu.title,
                    actions: [
                        composeAlertActions(menu.children),
                        [
                            Alert.Action(title: L10n.alertCancel, style: .cancel) { _ in },
                        ],
                    ].flatMap { $0 }
                )

                viewController.present(alert, style: .sheet(from: self.view, rect: self.bounds))
            }
        }

        return bag
    }
}
