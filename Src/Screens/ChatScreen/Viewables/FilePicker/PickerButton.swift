//
//  PickerButton.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-09-12.
//

import Flow
import Foundation
import UIKit
import ComponentKit

struct PickerButton: Viewable {
    let icon: UIImage

    func materialize(events _: ViewableEvents) -> (UIView, Signal<Void>) {
        let bag = DisposeBag()
        let button = UIControl()
        button.backgroundColor = .secondaryBackground
        bag += button.applyBorderColor { _ in
            .primaryBorder
        }
        button.layer.borderWidth = UIScreen.main.hairlineWidth
        button.layer.cornerRadius = 5

        let imageView = UIImageView()
        imageView.image = icon
        imageView.tintColor = .primaryText

        button.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(45)
            make.center.equalToSuperview()
        }

        return (button, Signal<Void> { callback in
            bag += button.signal(for: .touchUpInside).onValue(callback)
            return bag
        })
    }
}
