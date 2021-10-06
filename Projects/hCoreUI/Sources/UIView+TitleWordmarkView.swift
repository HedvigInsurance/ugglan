import Foundation
import UIKit

extension UIView {
    public static var titleWordmarkView: UIImageView {
        let imageView = UIImageView()
        imageView.image = hCoreUIAssets.wordmark.image
        imageView.contentMode = .scaleAspectFit

        imageView.snp.makeConstraints { make in make.width.equalTo(80) }

        return imageView
    }
}
