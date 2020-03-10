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
import Space

enum AssetType {
    case video, image, unknown
}

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
