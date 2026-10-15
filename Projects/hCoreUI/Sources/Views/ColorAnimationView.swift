import SwiftUI

public struct ColorAnimationView<InitialColor: hColor, AnimationColor: hColor>: View {
    @Binding var animationTrigger: Bool
    @State var showAnimation = false
    let color: InitialColor
    let animationColor: AnimationColor

    public init(
        animationTrigger: Binding<Bool>,
        color: InitialColor,
        animationColor: AnimationColor
    ) {
        _animationTrigger = animationTrigger
        self.color = color
        self.animationColor = animationColor
    }

    public var body: some View {
        backgroundColor
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
            .onChange(of: animationTrigger) {
                withAnimation {
                    showAnimation = true
                } completion: {
                    withAnimation {
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
