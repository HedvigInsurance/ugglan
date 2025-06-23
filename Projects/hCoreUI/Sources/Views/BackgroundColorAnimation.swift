import SwiftUI

public struct BackgorundColorAnimation<InitialColor: hColor, AnimationColor: hColor>: ViewModifier {
    @Binding var animationTrigger: Bool
    @State var showAnimation = false
    let color: InitialColor
    let animationColor: AnimationColor

    public init(animationTrigger: Binding<Bool>, color: InitialColor, animationColor: AnimationColor) {
        self._animationTrigger = animationTrigger
        self.color = color
        self.animationColor = animationColor
    }

    public func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
            .onChange(of: animationTrigger) { animate in
                withAnimation(.easeIn(duration: 0.2)) {
                    showAnimation = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showAnimation = false
                    }
                }
            }
    }

    @hColorBuilder
    private var backgroundColor: some hColor {
        if showAnimation {
            animationColor
        } else {
            color
        }
    }
}
