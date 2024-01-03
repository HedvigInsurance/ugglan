import Foundation

public struct ApplicationContext {
    public static var shared = ApplicationContext()
    @ReadWriteState public var isLoggedIn = false
    @ReadWriteState public var hasFinishedBootstrapping = false
    @ReadWriteState public var isDemoMode: Bool = false
}
