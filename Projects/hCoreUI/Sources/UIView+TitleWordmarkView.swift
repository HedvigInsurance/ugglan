//
//  UIImageView+TitleWordmarkView.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2021-06-28.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

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
