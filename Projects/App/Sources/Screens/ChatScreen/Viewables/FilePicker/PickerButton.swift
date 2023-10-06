import Flow
import Foundation
import UIKit
import hCore

struct PickerButton: Viewable {
    let icon: UIImage

    func materialize(events _: ViewableEvents) -> (UIView, Signal<Void>) {
        let bag = DisposeBag()
        let button = UIControl()
        button.backgroundColor = .brandNew(.secondaryBackground())
        bag += button.applyBorderColor { _ in .brandNew(.primaryBorderColor) }
        button.layer.borderWidth = UIScreen.main.hairlineWidth
        button.layer.cornerRadius = 8

        let imageView = UIImageView()
        imageView.image = icon
        imageView.tintColor = .brandNew(.primaryText())

        button.addSubview(imageView)

        imageView.snp.makeConstraints { make in make.height.width.equalTo(24)
            make.center.equalToSuperview()
        }

        return (
            button,
            Signal<Void> { callback in bag += button.signal(for: .touchUpInside).onValue(callback)
                return bag
            }
        )
    }
}
