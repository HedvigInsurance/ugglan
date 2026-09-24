import UIKit
import hCoreUI

extension UITabBarController {
    /// A colored dot drawn over a tab's icon.
    enum BadgeDot {
        case red
        case blue

        @MainActor
        fileprivate var color: UIColor {
            switch self {
            case .red: hSignalColor.Red.element.colorFor(.light, .base).color.uiColor()
            case .blue: hSignalColor.Blue.element.colorFor(.light, .base).color.uiColor()
            }
        }
    }

    private static let badgeDotTag = 999

    func updateBadgeDot(_ badge: BadgeDot?, forTabTitled title: String) {
        guard let viewControllers,
            let tabIndex = viewControllers.firstIndex(where: { $0.tabBarItem.title == title })
        else { return }

        tabBar.layoutIfNeeded()
        guard let buttonView = findTabButton(in: tabBar, at: tabIndex) else { return }

        guard let badge else {
            buttonView.viewWithTag(Self.badgeDotTag)?.removeFromSuperview()
            return
        }
        addOrRecolorBadgeDot(in: buttonView, color: badge.color)
    }

    private func addOrRecolorBadgeDot(in buttonView: UIView, color: UIColor) {
        // An already placed dot only needs recoloring — its constraints still hold.
        if let dot = buttonView.viewWithTag(Self.badgeDotTag) {
            dot.backgroundColor = color
            return
        }

        guard let imageView = buttonView.subviews.first(where: { $0 is UIImageView }) else { return }

        let dotSize: CGFloat = 8.5
        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = dotSize / 2
        dot.tag = Self.badgeDotTag
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.layer.zPosition = 1000
        buttonView.addSubview(dot)
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: dotSize),
            dot.heightAnchor.constraint(equalToConstant: dotSize),
            dot.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -2),
            dot.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -1),
        ])
    }

    private func findTabButton(in tabBar: UITabBar, at index: Int) -> UIView? {
        // iOS 26: buttons inside _UITabBarPlatterView → ContentView
        if let platterView = tabBar.subviews.first(where: {
            String(describing: type(of: $0)).contains("PlatterView")
        }),
            let contentView = platterView.subviews.first(where: {
                String(describing: type(of: $0)) == "ContentView"
            })
        {
            let buttons = sortedButtons(in: contentView, matching: "TabButton")
            return index < buttons.count ? buttons[index] : nil
        }

        // iOS 18: buttons are direct children of UITabBar
        let buttons = sortedButtons(in: tabBar, matching: "UITabBarButton")
        return index < buttons.count ? buttons[index] : nil
    }

    private func sortedButtons(in container: UIView, matching typeName: String) -> [UIView] {
        container.subviews
            .filter { String(describing: type(of: $0)).contains(typeName) }
            .sorted { $0.frame.origin.x < $1.frame.origin.x }
    }
}
