import Foundation
import UnleashProxyClientSwift

public struct ApplicationContext {
    public static var shared = ApplicationContext()
    @ReadWriteState public var isLoggedIn = false
    @ReadWriteState public var hasFinishedBootstrapping = false
    @ReadWriteState public var unleashClient: UnleashClient = UnleashClient(
        unleashUrl: "https://unleash.prod.hedvigit.com/api/",
        clientKey: ""
    )
    @ReadWriteState public var isDemoMode: Bool = false
}
