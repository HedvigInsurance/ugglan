import Foundation
import SwiftUI
import UIKit
import hCore

public struct Spacing {
    public init(height: Float) { self.height = height }
    public let height: Float
}

extension Spacing: View {
    public var body: some View {
        Color.clear.frame(height: CGFloat(height))
    }
}
