import Foundation
import SwiftUI

public enum ImpactGenerator {
    public static func soft() {
        Task {
            let generator = await UIImpactFeedbackGenerator(style: .soft)
            await generator.impactOccurred()
        }
    }

    public static func light() {
        Task {
            let generator = await UIImpactFeedbackGenerator(style: .light)
            await generator.impactOccurred()
        }
    }
}
