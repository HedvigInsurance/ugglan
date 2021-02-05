import Flow
import Foundation
import Presentation
import UIKit

public enum MenuStyle {
    case `default`, destructive
}

public struct MenuChild {
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

public struct Menu {
    let title: String?
    let children: [MenuChild]

    public init(
        title: String?,
        children: [MenuChild]
    ) {
        self.title = title
        self.children = children
    }
}

public extension UIBarButtonItem {
    func attachSinglePressMenu(viewController: UIViewController, menu: Menu) -> Disposable {
        let bag = DisposeBag()

        if #available(iOS 14, *) {
            self.menu = UIMenu(
                title: menu.title ?? "",
                children: menu.children.map { menuChild in
                    UIAction(
                        title: menuChild.title,
                        image: menuChild.image,
                        attributes: menuChild.style == .destructive ? .destructive : []
                    ) { _ in
                        menuChild.handler()
                    }
                }
            )
        } else {
            bag += onValue {
                let alert = Alert<Void>(
                    title: menu.title,
                    actions: [
                        menu.children.map { menuChild in
                            Alert.Action(
                                title: menuChild.title,
                                style: menuChild.style == .destructive ? .destructive : .default
                            ) { _ in
                                menuChild.handler()
                            }
                        },
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
