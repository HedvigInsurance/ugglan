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
        self._animationTrigger = animationTrigger
        self.color = color
        self.animationColor = animationColor
    }
    public var body: some View {
        backgroundColor
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusL))
            .onChange(of: animationTrigger) { animate in
                if #available(iOS 17.0, *) {
                    withAnimation {
                        showAnimation = true
                    } completion: {
                        withAnimation {
                            showAnimation = false
                        }
                    }
                } else {
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
