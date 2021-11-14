import Foundation
import SwiftUI

public struct WordmarkActivityIndicator: View {
    @State var rotating: Bool = false
    @State var hasEntered: Bool = false
    var size: Size
    
    public enum Size {
        case standard
        case small
    }
    
    public init(_ size: Size) {
        self.size = size
    }
    
    var frameSize: CGFloat {
        switch size {
        case .standard:
            return 40
        case .small:
            return 20
        }
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 1.0)
                .opacity(0.5)
                .foregroundColor(hLabelColor.primary)
            
            Circle()
                .trim(from: 0.0, to: 0.7)
                .stroke(style: StrokeStyle(lineWidth: 1.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(hLabelColor.primary)
                .rotationEffect(rotating ? Angle(degrees: 0) : Angle(degrees: 360))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: self.rotating)
            
            hText("H", style: .largeTitle).minimumScaleFactor(0.1).padding(1.5)
        }.onAppear {
            self.rotating.toggle()
        }
        .frame(width: frameSize, height: frameSize)
        .scaleEffect(hasEntered ? 1 : 0.8)
        .animation(.interpolatingSpring(stiffness: 200, damping: 15).delay(0.2), value: hasEntered)
        .onAppear {
            self.hasEntered = true
        }
    }
}
