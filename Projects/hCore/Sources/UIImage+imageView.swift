import Foundation
import UIKit

extension UIImage {
    public func imageView(height: CGFloat? = nil, width: CGFloat? = nil) -> UIImageView {
        let view = UIImageView()

        view.image = self
        view.contentMode = .scaleAspectFit

        view.snp.makeConstraints { make in
            if let height = height {
                make.height.equalTo(height)
            }

            if let width = width {
                make.width.equalTo(width)
            }
        }

        return view
    }
}
