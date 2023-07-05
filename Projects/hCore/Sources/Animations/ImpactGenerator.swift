import Foundation
import UIKit

public struct ImpactGenerator {
    public static func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
}
