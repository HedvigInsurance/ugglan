import Foundation
import SwiftUI
import hCore

public struct Spacing {
    public init(height: Float) {
        self.height = height
        width = nil
    }

    public init(width: Float) {
        self.width = width
        height = nil
    }

    let width: Float?
    let height: Float?
}

extension Spacing: View {
    public var body: some View {
        if let width {
            Color.clear.frame(width: CGFloat(width))
        } else {
            Color.clear.frame(height: CGFloat(height ?? 0))
        }
    }
}
