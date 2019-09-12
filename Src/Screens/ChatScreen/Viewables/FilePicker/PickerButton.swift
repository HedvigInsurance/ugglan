//
//  PickerButton.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-09-12.
//

import Foundation
import UIKit
import Flow

struct PickerButton: Viewable {
    let icon: UIImage
    
    func materialize(events: ViewableEvents) -> (UIView, Signal<Void>) {
        let bag = DisposeBag()
        let button = UIControl()
        button.backgroundColor = .secondaryBackground
        button.layer.borderColor = UIColor.primaryBorder.cgColor
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
