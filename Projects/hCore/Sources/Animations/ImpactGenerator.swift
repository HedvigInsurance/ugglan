import Foundation
import SwiftUI

public enum ImpactGenerator {
    public static func soft() {
        Task {
            let generator = await UIImpactFeedbackGenerator(style: .soft)
            await generator.impactOccurred()
        }
    }
}
