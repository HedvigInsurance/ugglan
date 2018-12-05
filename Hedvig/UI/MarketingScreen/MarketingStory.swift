//
//  MarketingStory.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-28.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import AVKit
import CoreMedia
import Disk
import Flow
import Form
import Foundation
import UIKit

enum AssetType {
    case video, image, unknown
}

struct MarketingStory: Decodable, Hashable {
    var assetURL: String?
    var assetMimeType: String?
    var duration: TimeInterval
    var id: String

    func cacheData() -> Future<Void> {
        return Future<Void> { completion in
            DispatchQueue.global(qos: .background).async {
                let assetType = self.assetType()

                if assetType == .video {
                    self.cacheVideo()
                }

                if assetType == .image {
                    self.cacheImage()
                }

                completion(.success(Void()))
            }

            return NilDisposer()
        }
    }

    func assetType() -> AssetType {
        guard let mimeType = assetMimeType else { return .unknown }

        if mimeType.contains("video") {
            return .video
        } else if mimeType.contains("image") {
            return .image
        }

        return .unknown
    }

    func cacheFileName() -> String {
        guard let url = assetURL else { return "" }
        let assetType = self.assetType()

        if assetType == .video {
            return url + ".mp4"
        }

        return url
    }

    func cacheVideo() {
        guard let url = assetURL else { return }
        let cacheFileName = self.cacheFileName()
        let isCached = Disk.exists(cacheFileName, in: .caches)

        if isCached {
            return
        }

        let data = try? Data(contentsOf: URL(string: url)!, options: [])

        if let data = data {
            try? Disk.save(data, to: .caches, as: cacheFileName)
        }
    }

    func cacheImage() {
        guard let url = assetURL else { return }
        let cacheFileName = self.cacheFileName()

        let isCached = Disk.exists(cacheFileName, in: .caches)

        if isCached {
            return
        }

        let data = try? Data(contentsOf: URL(string: url)!, options: [])

        if let data = data {
            try? Disk.save(data, to: .caches, as: cacheFileName)
        }
    }

    func playerAsset() -> AVAsset? {
        let cacheFileName = self.cacheFileName()

        cacheVideo()

        let fileSystemUrl = try? Disk.url(for: cacheFileName, in: .caches)
        return AVAsset(url: fileSystemUrl!)
    }

    func imageAsset() -> UIImage? {
        let cacheFileName = self.cacheFileName()

        cacheImage()

        let data = try? Disk.retrieve(cacheFileName, from: .caches, as: Data.self)
        return UIImage(data: data!)
    }

    init(apollo marketingStoryData: MarketingStoriesQuery.Data.MarketingStory) {
        assetURL = marketingStoryData.asset?.url
        assetMimeType = marketingStoryData.asset?.mimeType
        duration = marketingStoryData.duration ?? 0
        id = marketingStoryData.id
    }
}

extension MarketingStory: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (MarketingStory) -> Disposable) {
        let view = UIView()
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale

        let videoPlayerLayer = AVPlayerLayer()
        videoPlayerLayer.videoGravity = .resizeAspectFill

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        return (view, { marketingStory in
            let bag = DisposeBag()
            guard let mimeType = marketingStory.assetMimeType else { return bag }

            if mimeType.contains("video") {
                imageView.removeFromSuperview()

                videoPlayerLayer.frame = view.bounds
                view.layer.addSublayer(videoPlayerLayer)

                DispatchQueue.global(qos: .background).async {
                    guard let playerAsset = marketingStory.playerAsset() else { return }

                    playerAsset.loadValuesAsynchronously(forKeys: ["tracks", "duration"], completionHandler: {
                        let playerItem = AVPlayerItem(asset: playerAsset)

                        let videoPlayer = AVPlayer(playerItem: playerItem)
                        videoPlayer.isMuted = true
                        videoPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                        videoPlayerLayer.player = videoPlayer

                        videoPlayer.play()
                    })
                }
            } else if mimeType.contains("image") {
                videoPlayerLayer.removeFromSuperlayer()

                DispatchQueue.global(qos: .background).async {
                    guard let image = marketingStory.imageAsset() else { return }
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }

                view.addSubview(imageView)

                imageView.snp.makeConstraints { make in
                    make.width.equalTo(view)
                    make.height.equalTo(view)
                    make.center.equalTo(view)
                }
            }

            return bag
        })
    }
}
