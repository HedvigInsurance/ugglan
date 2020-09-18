import Flow
import Form
import Foundation
import hGraphQL
import Kingfisher
import UIKit

struct KeyGearImageCarouselItem {
    let resource: Either<URL, GraphQL.KeyGearItemCategory>
}

extension KeyGearImageCarouselItem: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (KeyGearImageCarouselItem) -> Disposable) {
        let containerView = UIView()

        let imageView = UIImageView()
        containerView.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        imageView.clipsToBounds = true

        return (containerView, { `self` in
            let bag = DisposeBag()

            if let imageUrl = self.resource.left {
                imageView.kf.setImage(with: imageUrl, options: [
                    .keepCurrentImageWhileLoading,
                    .cacheOriginalImage,
                    .processor(DownsamplingImageProcessor(size: imageView.frame.size)),
                    .scaleFactor(UIScreen.main.scale),
                    .backgroundDecode,
                    .transition(.fade(0.25)),
                ])
                imageView.contentMode = .scaleAspectFill
                imageView.snp.updateConstraints { make in
                    make.top.bottom.leading.trailing.equalToSuperview()
                }
            } else if let category = self.resource.right {
                imageView.image = category.image
                imageView.contentMode = .scaleAspectFit

                imageView.snp.updateConstraints { make in
                    make.top.equalToSuperview().inset(100)
                    make.bottom.equalToSuperview().inset(50)
                    make.leading.trailing.equalToSuperview()
                }
            }

            return bag
        })
    }
}
