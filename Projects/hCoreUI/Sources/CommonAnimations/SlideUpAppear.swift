//
//  SlideUpAppear.swift
//  SlideUpAppear
//
//  Created by Sam Pettersson on 2021-09-12.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct SlideUpAppearAnimationModifier: ViewModifier {
    var delay: CGFloat
    @State var animateAppearPerformed = false
    @State var height: CGFloat = 0
    
    var offset: CGFloat {
        if height == 0 {
            return .infinity
        }
        
        return animateAppearPerformed ? 0 : height * 2
    }
    
    func body(content: Content) -> some View {
        content
        .background(GeometryReader { geo in
            Rectangle().fill(.clear).onReceive(Just(geo.size.height)) { height in
                if height != self.height {
                    self.height = height
                }
            }
        })
        .onReceive(Just(height), perform: { height in
            if height != 0 {
                withAnimation(.spring().delay(delay)) {
                    animateAppearPerformed = true
                }
            }
        })
        .opacity(animateAppearPerformed ? 1 : 0)
        .offset(x: 0, y: offset)
    }
}

extension View {
    public func slideUpAppearAnimation(delay: CGFloat = 0.2) -> some View {
        self.modifier(SlideUpAppearAnimationModifier(delay: delay))
    }
}
