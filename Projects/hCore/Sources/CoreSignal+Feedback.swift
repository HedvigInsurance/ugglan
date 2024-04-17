import Flow
import Foundation
import SwiftUI

public enum FeedbackType { case error, warning, success, selection, impactLight, impactMedium, impactHeavy }

private enum Feedback {
    static func generateNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    static func generateSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    static func generateImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

extension CoreSignal {
    /// Generate haptic feedback
    public func feedback(type: FeedbackType) -> Disposable {
        if !UITraitCollection.isCatalyst {
            let bag = DisposeBag()
            bag += onValue { _ in
                switch type {
                case .error: Feedback.generateNotification(.error)
                case .warning: Feedback.generateNotification(.warning)
                case .success: Feedback.generateNotification(.success)
                case .selection: Feedback.generateSelection()
                case .impactLight: Feedback.generateImpact(.light)
                case .impactMedium: Feedback.generateImpact(.medium)
                case .impactHeavy: Feedback.generateImpact(.heavy)
                }
            }

            return bag
        } else {
            return NilDisposer()
        }
    }
}
