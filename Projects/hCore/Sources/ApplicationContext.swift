import Combine
import Foundation

public actor ApplicationContext {
    public static let shared = ApplicationContext()

    private init() {}
    private let isLoggedInSubject = CurrentValueSubject<Bool, Never>(false)

    public var isLoggedInPublisher: AnyPublisher<Bool, Never> {
        return isLoggedInSubject.eraseToAnyPublisher()
    }

    public var isLoggedIn: Bool {
        return isLoggedInSubject.value
    }

    public func setValue(to isLoggedIn: Bool) {
        isLoggedInSubject.send(isLoggedIn)
    }
}
