import Combine
import Foundation
import SwiftUI

struct SlideUpFadeAppearAnimationModifier: ViewModifier {
    var delay: Double
    @State var animateAppearPerformed = false
    @State var height: CGFloat = 0

    var offset: CGFloat {
        if height == 0 {
            return 0
        }

        return animateAppearPerformed ? 0 : height * 0.1
    }

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear.onReceive(Just(geo.size.height)) { height in
                        if height != self.height {
                            self.height = height
                        }
                    }
                }
            )
            .onReceive(
                Just(height),
                perform: { height in
                    if height != 0 {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(delay)) {
                            animateAppearPerformed = true
                        }
                    }
                }
            )
            .opacity(animateAppearPerformed ? 1 : 0)
            .offset(x: 0, y: offset)
            .scaleEffect(animateAppearPerformed ? 1 : 0.92)
    }
}

public extension View {
    func slideUpFadeAppearAnimation(delay: Double = 0.2) -> some View {
        modifier(SlideUpFadeAppearAnimationModifier(delay: delay))
    }
}
