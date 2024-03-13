import Combine
import Foundation
import SwiftUI

public protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    public var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },

            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}
