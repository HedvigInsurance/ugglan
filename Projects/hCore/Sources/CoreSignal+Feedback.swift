//
//  CoreSignal+Feedback.swift
//  FlowFeedback
//
//  Created by Sam Pettersson on 2018-11-30.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//
import Flow
import Foundation
import UIKit

public enum FeedbackType {
    case error, warning, success, selection, impactLight, impactMedium, impactHeavy
}

@available(iOS 10.0, *)
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

public extension CoreSignal {
    /// Generate haptic feedback
    func feedback(type: FeedbackType) -> Disposable {
        if #available(iOS 10.0, *), !UITraitCollection.isCatalyst {
            let bag = DisposeBag()

            bag += onValue { _ in
                switch type {
                case .error:
                    Feedback.generateNotification(.error)
                case .warning:
                    Feedback.generateNotification(.warning)
                case .success:
                    Feedback.generateNotification(.success)
                case .selection:
                    Feedback.generateSelection()
                case .impactLight:
                    Feedback.generateImpact(.light)
                case .impactMedium:
                    Feedback.generateImpact(.medium)
                case .impactHeavy:
                    Feedback.generateImpact(.heavy)
                }
            }

            return bag
        } else {
            return NilDisposer()
        }
    }
}
