//
//  Fonts.swift
//  CoreUI
//
//  Created by Sam Pettersson on 2020-05-08.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

class FontBundleToken {}

struct Fonts {
    static var favoritStdBook: UIFont = {
        let fontPath = Bundle(for: FontBundleToken.self).path(
            forResource: "FavoritStd-Book",
            ofType: "otf"
        )
        let inData = NSData(contentsOfFile:fontPath!)
        let provider = CGDataProvider(data: inData!)
        
        let font = CGFont(provider!)
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(font!, &error)
        
        return UIFont(
            name: "FavoritStd-Book",
            size: UIFont.systemFontSize
        )!
    }()
}
