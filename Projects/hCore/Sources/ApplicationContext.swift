import Foundation
import UnleashProxyClientSwift

public struct ApplicationContext {
    public static var shared = ApplicationContext()
    @ReadWriteState public var isLoggedIn = false
    @ReadWriteState public var hasFinishedBootstrapping = false
}
