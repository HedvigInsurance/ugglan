import Flow
import Foundation
import SwiftUI
import UIKit
import hCore

struct hGradient: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var oldGradientType: GradientType
    @Binding var newGradientType: GradientType
    @Binding var animate: Bool

    @State private var hasAnimatedCurrentTypes = false
    @State private var progress: CGFloat = 0
    @State private var colors: [Color] = []

    var body: some View {
        if #available(iOS 14.0, *) {
            Rectangle()
                .animatableGradient(
                    fromGradient: Gradient(colors: oldGradientType.colors(for: colorScheme)),
                    toGradient: Gradient(colors: newGradientType.colors(for: colorScheme)),
                    progress: animate ? progress : 1
                )
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    if !hasAnimatedCurrentTypes {
                        self.progress = 0
                        withAnimation(.easeOut(duration: 1.0)) {
                            self.progress = 1
                        }
                        hasAnimatedCurrentTypes = true
                    } else {
                        self.progress = 1
                    }
                }
                .onChange(of: newGradientType) { _ in
                    hasAnimatedCurrentTypes = false
                }
        } else {
            EmptyView()
        }
    }
}
