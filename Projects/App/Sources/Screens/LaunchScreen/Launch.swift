import Flow
import Foundation
import Presentation
import UIKit
import hCore

struct Launch { let completeAnimationCallbacker = Callbacker<Void>() }

extension Launch: Presentable {
	func materialize() -> (UIView, Future<Void>) {
		let bag = DisposeBag()

		let containerView = UIView()
		containerView.backgroundColor = .brand(.primaryBackground())

		let imageView = UIImageView()
		imageView.image = Asset.wordmark.image
		imageView.contentMode = .scaleAspectFit

		containerView.addSubview(imageView)

		imageView.snp.makeConstraints { make in make.width.equalTo(140)
			make.height.equalTo(50)
			make.center.equalToSuperview()
		}

		return (
			containerView,
			Future { completion in
				bag += self.completeAnimationCallbacker.delay(by: 0.1)
					.animated(style: AnimationStyle.easeOut(duration: 0.5)) {
                        containerView.alpha = 0
					}
					.onValue { _ in completion(.success(())) }

				return bag
			}
		)
	}
}
