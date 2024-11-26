import Foundation

@MainActor
public var forceLogoutHook: () -> Void = {
    assertionFailure("Force logout not specified by application, this is an error")
}
