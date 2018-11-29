//
//  MarketingStory.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-28.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import AVKit
import CoreMedia
import Flow
import Form
import Foundation
import UIKit

struct MarketingStory: Decodable, Hashable {
    var assetURL: String?
    var assetMimeType: String?

    init(apollo marketingStoryData: MarketingStoriesQuery.Data.MarketingStory) {
        assetURL = marketingStoryData.asset?.url
        assetMimeType = marketingStoryData.asset?.mimeType
    }
}

extension MarketingStory: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (MarketingStory) -> Disposable) {
        let view = UIView()

        return (view, { marketingStory in
            let disposer = NilDisposer()
            guard let url = marketingStory.assetURL else { return disposer }
            guard let mimeType = marketingStory.assetMimeType else { return disposer }

            if mimeType.contains("video") {
                let videoUrl = URL(string: url)
                let videoPlayer = AVPlayer(url: videoUrl!)
                let videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
                videoPlayerLayer.frame = view.bounds

                view.layer.addSublayer(videoPlayerLayer)

                videoPlayer.play()
            } else if mimeType.contains("image") {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill

                let imageUrl = URL(string: url)
                let imageData = try? Data(contentsOf: imageUrl!)

                if imageData != nil {
                    imageView.image = UIImage(data: imageData!)
                }

                view.addSubview(imageView)

                imageView.snp.makeConstraints { make in
                    make.width.equalTo(view)
                    make.height.equalTo(view)
                    make.center.equalTo(view)
                }
            }

            return disposer
        })
    }
}
