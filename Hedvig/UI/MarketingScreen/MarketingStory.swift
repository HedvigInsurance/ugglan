//
//  MarketingStory.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-28.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import CoreMedia
import Flow
import Form
import Foundation

struct MarketingStory: Decodable, Hashable {
    var assetURL: String?
    var assetMimeType: String?

    init(apollo marketingStoryData: MarketingStoriesQuery.Data.MarketingStory) {
        assetURL = marketingStoryData.asset?.url
        assetMimeType = marketingStoryData.asset?.mimeType
    }
}

extension MarketingStory: Reusable {
    static func makeAndConfigure() -> (make: MarketingStoryView, configure: (MarketingStory) -> Disposable) {
        let view = MarketingStoryView()

        return (view, { marketingStory in
            let disposer = NilDisposer()

            guard let url = marketingStory.assetURL else { return disposer }
            guard let mimeType = marketingStory.assetMimeType else { return disposer }
            view.update(url: url, mimeType: mimeType)

            return disposer
        })
    }
}
