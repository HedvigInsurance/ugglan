//
//  MarketingStoryView.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-29.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import AVKit
import Foundation
import UIKit

class MarketingStoryView: UIView {
    var imageView: UIImageView?
    var videoPlayerLayer: AVPlayerLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        clipsToBounds = true
    }

    func update(url: String, mimeType: String) {
        if mimeType.contains("video") {
            imageView?.removeFromSuperview()
            imageView = nil

            let videoUrl = URL(string: url)
            let videoPlayer = AVPlayer(url: videoUrl!)
            videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
            videoPlayerLayer!.frame = bounds

            layer.addSublayer(videoPlayerLayer!)

            videoPlayer.play()
        } else {
            videoPlayerLayer?.removeFromSuperlayer()
            videoPlayerLayer = nil

            imageView = UIImageView()

            imageView!.contentMode = .scaleAspectFill

            let imageUrl = URL(string: url)
            let imageData = try? Data(contentsOf: imageUrl!)

            if imageData != nil {
                imageView?.image = UIImage(data: imageData!)
            }

            addSubview(imageView!)

            imageView!.snp.makeConstraints { make in
                make.width.equalTo(self)
                make.height.equalTo(self)
                make.center.equalTo(self)
            }
        }
    }
}
