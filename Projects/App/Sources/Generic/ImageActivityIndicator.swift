//
//  ImageActivityIndicator.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-13.
//

import Foundation
import Kingfisher
import UIKit
import Core

struct ImageActivityIndicator: Indicator {
    let indicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    var view: IndicatorView {
        indicatorView
    }

    func startAnimatingView() { indicatorView.startAnimating() }
    func stopAnimatingView() { indicatorView.stopAnimating() }

    init() {
        indicatorView.color = UIColor(dynamic: { traits -> UIColor in
            traits.userInterfaceStyle == .dark ? .white : .black
        })
    }
}
