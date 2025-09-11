import Combine
import Foundation
import SwiftUI

public protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<CGFloat?, Never> { get }
}

extension KeyboardReadable {
    public var keyboardPublisher: AnyPublisher<CGFloat?, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { data in
                    if let keyboardFrame: NSValue = data.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
                    {
                        let keyboardRectangle = keyboardFrame.cgRectValue
                        let keyboardHeight = keyboardRectangle.height
                        return keyboardHeight
                    }
                    return nil
                },

            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in
                    nil
                }
        )
        .eraseToAnyPublisher()
    }
}

public protocol KeyboardReadableHeight {
    var keyboardHeightPublisher: AnyPublisher<CGFloat?, Never> { get }
}

extension KeyboardReadableHeight {
    public var keyboardHeightPublisher: AnyPublisher<CGFloat?, Never> {
        Publishers.Merge3(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { data in
                    if let keyboardFrame: NSValue = data.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
                    {
                        let keyboardRectangle = keyboardFrame.cgRectValue
                        let keyboardHeight = keyboardRectangle.height
                        return keyboardHeight
                    }
                    return nil
                },

            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in
                    nil
                },

            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillChangeFrameNotification)
                .map { data in
                    if let keyboardFrame: NSValue = data.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
                    {
                        let keyboardRectangle = keyboardFrame.cgRectValue
                        let keyboardHeight = keyboardRectangle.height
                        return keyboardHeight
                    }
                    return nil
                }
        )
        .eraseToAnyPublisher()
    }
}
