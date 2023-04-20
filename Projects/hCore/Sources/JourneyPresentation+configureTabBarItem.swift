import Flow
import Foundation
import Presentation
import UIKit

extension JourneyPresentation {
    /// set tab bar item with title, image asset and selected image asset
    public func configureTabBarItem(title: String, image: UIImage, selectedImage: UIImage) -> some JourneyPresentation {
        self.addConfiguration({ presenter in
            let tabBarItem = UITabBarItem(
                title: title,
                image: image,
                selectedImage: selectedImage
            )
            presenter.viewController.tabBarItem = tabBarItem
        })
    }
}
