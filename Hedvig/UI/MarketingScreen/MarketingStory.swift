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

extension HedvigColor: Decodable {}

struct MarketingStory: Decodable, Hashable {
    var assetURL: String?
    var assetMimeType: String?
    var duration: TimeInterval
    var id: String
    var backgroundColor: HedvigColor

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
        backgroundColor = marketingStoryData.backgroundColor
    }
}

class MarketingStoryVideoCell: UICollectionViewCell {
    let videoPlayerLayer = AVPlayerLayer()
    let videoPlayer = AVPlayer()
    var duration: TimeInterval = 0
    var cellDidLoad: () -> Void = {}

    override init(frame: CGRect) {
        super.init(frame: frame)
        videoPlayerLayer.videoGravity = .resizeAspectFill
        videoPlayer.isMuted = true
    }

    func play(marketingStory: MarketingStory) {
        backgroundColor = HedvigColors.from(
            apollo: marketingStory.backgroundColor
        )
        duration = marketingStory.duration

        videoPlayerLayer.frame = bounds
        layer.addSublayer(videoPlayerLayer)

        DispatchQueue.global(qos: .background).async {
            guard let playerAsset = marketingStory.playerAsset() else { return }

            let playerItem = AVPlayerItem(asset: playerAsset)
            self.videoPlayer.replaceCurrentItem(with: playerItem)
            self.videoPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
            self.videoPlayerLayer.player = self.videoPlayer

            if #available(iOS 10.0, *) {
                self.videoPlayer.playImmediately(atRate: 1)
                try? AVAudioSession.sharedInstance().setCategory(
                    AVAudioSession.Category.ambient,
                    mode: .default,
                    options: .mixWithOthers
                )
            } else {
                self.videoPlayer.play()
            }

            self.cellDidLoad()
        }
    }

    func resume() {
        if #available(iOS 10.0, *) {
            self.videoPlayer.playImmediately(atRate: 1)
        }
    }

    func pause() {
        videoPlayer.pause()
    }

    func end() {
        if let duration = videoPlayer.currentItem?.duration {
            videoPlayer.seek(to: duration, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.positiveInfinity)
        }
    }

    func restart() {
        videoPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))

        if #available(iOS 10.0, *) {
            self.videoPlayer.playImmediately(atRate: 1)
        } else {
            videoPlayer.play()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MarketingStoryImageCell: UICollectionViewCell {
    let imageView = UIImageView()
    var cellDidLoad: () -> Void = {}

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }

    func show(marketingStory: MarketingStory) {
        backgroundColor = HedvigColors.from(
            apollo: marketingStory.backgroundColor
        )

        DispatchQueue.global(qos: .background).async {
            guard let image = marketingStory.imageAsset() else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
                self.cellDidLoad()
            }
        }

        addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
