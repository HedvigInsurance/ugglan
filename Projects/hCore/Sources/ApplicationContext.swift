import Combine
import Foundation

public class ApplicationContext {
    public static var shared = ApplicationContext()

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
