//
//  CachedImage.swift
//  Ugglan
//
//  Created by Gustaf Gunér on 2019-04-10.
//

import Disk
import Flow
import Foundation
import UIKit

struct CachedImage {
    let url: URL
}

extension CachedImage: Viewable {
    func materialize(events _: ViewableEvents) -> (UIImageView, Disposable) {
        let imageView = UIImageView()

        let bag = DisposeBag()

        let urlString = String(describing: url)

        func cacheImage(url _: URL) {
            let isCached = Disk.exists(urlString, in: .caches)

            if isCached {
                return
            }

            let data = try? Data(contentsOf: URL(string: urlString)!, options: [])

            if let data = data {
                try? Disk.save(data, to: .caches, as: urlString)
            }
        }

        cacheImage(url: url)

        let data = try? Disk.retrieve(urlString, from: .caches, as: Data.self)
        imageView.image = UIImage(data: data!)
        imageView.contentMode = .scaleAspectFit

        return (imageView, bag)
    }
}
