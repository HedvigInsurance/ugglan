import Foundation
import SwiftUI

public struct ImpactGenerator {
    public static func soft() {
        Task {
            let generator = await UIImpactFeedbackGenerator(style: .soft)
            await generator.impactOccurred()
        }
    }
}
