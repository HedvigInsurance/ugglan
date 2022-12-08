import Foundation

// force logout user
public var forceLogoutHook: () -> Void = {
    assertionFailure("Force logout not specified by application, this is an error")
}
