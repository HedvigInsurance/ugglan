//
//  MarketingStoryIndicator.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-13.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit

struct MarketingStoryIndicator: Decodable, Hashable {
    let duration: TimeInterval
    let id: String
    var focused: Bool
    var shown: Bool

    init(duration: TimeInterval, focused: Bool, id: String, shown: Bool) {
        self.duration = duration
        self.focused = focused
        self.id = id
        self.shown = shown
    }
}
