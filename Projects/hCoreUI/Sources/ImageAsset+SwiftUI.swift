//
//  ImageAsset+SwiftUI.swift
//  ImageAsset+SwiftUI
//
//  Created by Sam Pettersson on 2021-08-24.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI

extension ImageAsset {
    /// a SwiftUI view with the image asset
    public var view: SwiftUI.Image {
        .init(uiImage: self.image)
    }
}
