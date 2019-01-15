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
    var presentingViewController: UIViewController { get }

    associatedtype PreviewMatter: Presentable
    func preview() -> (PreviewMatter, PresentationOptions)
}

extension Previewable where Self.PreviewMatter.Matter == UIViewController, Self.PreviewMatter.Result == Disposable {
    func registerPreview(_ view: UIView) -> Disposable {
        return presentingViewController.registerForPreviewing(sourceView: view, previewable: self)
    }
}
