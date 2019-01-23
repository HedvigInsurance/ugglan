//
//  Previewable.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation

/// Something that can preview something that is a presentable 👀
protocol Previewable {
    associatedtype PreviewMatter: Presentable
    func preview() -> (PreviewMatter, PresentationOptions)
}
