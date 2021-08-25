//
//  ActivityIndicator.swift
//  ActivityIndicator
//
//  Created by Sam Pettersson on 2021-08-25.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI

public struct ActivityIndicator: UIViewRepresentable {
    var isAnimating: Bool
    
    public init(isAnimating: Bool) {
        self.isAnimating = isAnimating
    }

    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIActivityIndicatorView {
        UIActivityIndicatorView()
    }
    
    public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
