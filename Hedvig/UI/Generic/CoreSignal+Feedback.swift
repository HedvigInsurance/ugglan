//
//  CoreSignal+Feedback.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-30.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation

enum FeedbackType {
    case error, warning, success, selection, impactLight, impactMedium, impactHeavy
}

private struct Feedback {
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
    func feedback(type: FeedbackType) -> Disposable {
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
    }
}
