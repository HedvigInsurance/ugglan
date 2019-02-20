//
//  BackgroundLabel.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import UIKit

struct BackgroundWithLabel {
    let labelText: DynamicString
    let backgroundColor: UIColor?
    let backgroundImage: UIImage?
    let textColor: UIColor?
    
    init(
        labelText: DynamicString,
        backgroundColor: UIColor? = .purple,
        backgroundImage: UIImage? = nil,
        textColor: UIColor? = .white
    ) {
        self.labelText = labelText
        self.backgroundColor = backgroundColor
        self.backgroundImage = backgroundImage
        self.textColor = textColor
    }
}

extension BackgroundWithLabel: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let view = UIView()
        view.backgroundColor = backgroundColor
        
        if backgroundImage != nil {
            let imageView = UIImageView()
            imageView.image = backgroundImage
            imageView.contentMode = .scaleAspectFit
            
            view.addSubview(imageView)
            
            imageView.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalToSuperview()
            }
        }
        
        let label = UILabel()
        bag += label.setDynamicText(labelText)
        
        label.clipsToBounds = true
        label.textAlignment = .center
        label.font = HedvigFonts.soRayExtraBold?.withSize(44)
        label.textColor = textColor
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = false
        
        let labelContainer = UIView()
        labelContainer.addSubview(label)
        
        bag += label.didLayoutSignal.onValue { _ in
            label.snp.remakeConstraints { make in
                make.width.equalToSuperview().inset(20)
                make.height.equalToSuperview().inset(20)
                make.center.equalToSuperview()
            }
        }
        
        view.addSubview(labelContainer)
        
        labelContainer.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        view.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        return (view, bag)
    }
}
