//
//  UIImageView+Cache.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-03-21.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Disk

extension UIImageView {
    func imageFromURL(url: String) -> Void {
        UIImageView.cacheImage(url: url)
        let data = try? Disk.retrieve(url, from: .caches, as: Data.self)
        self.image = UIImage(data: data!)
    }
    
    private static func cacheImage(url: String) -> Void {
        let isCached = Disk.exists(url, in: .caches)
    
        if isCached {
            return
        }
    
        let data = try? Data(contentsOf: URL(string: url)!, options: [])
    
        if let data = data {
            try? Disk.save(data, to: .caches, as: url)
        }
    }
}
