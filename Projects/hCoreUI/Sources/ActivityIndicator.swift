//
//  ActivityIndicator.swift
//  ActivityIndicator
//
//  Created by Sam Pettersson on 2021-09-23.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI

 public struct ActivityIndicator: UIViewRepresentable {
     var isAnimating: Bool

     public init(
         isAnimating: Bool
     ) {
         self.isAnimating = isAnimating
     }

     public func makeUIView(context: Context) -> UIActivityIndicatorView {
         UIActivityIndicatorView()
     }

     public func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
         isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
     }
 }
