import AutomaticLog
import Combine
import SwiftUI
import hCore

@LogAll(.error)
@MainActor
class AnalyticsService {
    @Inject var client: AnalyticsClient
    @Inject var eventClient: EventTrackingClient
    fileprivate var setDeviceInfoTask: Task<(), Never>?
    fileprivate var userId: String?
    fileprivate var analyticsConsentCancellable: AnyCancellable?

    init() {
        observeAnalyticsConsent()
    }

    func fetchAndSetUserId() async throws {
        let userId = try await client.fetchUserId()
        setWith(userId: userId)
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        setDeviceInfo(pushNotificationEnabled: settings.authorizationStatus == .authorized)
    }

    func setWith(userId: String) {
        self.userId = userId
        client.setWith(userId: userId)
        eventClient.setUserId(userId)
    }

    func clearUserId() {
        userId = nil
        eventClient.setUserId(nil)
    }

    deinit {
        setDeviceInfoTask?.cancel()
    }
}

// Lives in an extension so `@LogAll` doesn't attach `@Log` to it — the compiler crashes
// ("Failed to produce diagnostic") when this `Task { [weak self] in }` closure is inside a body macro.
extension AnalyticsService {
    fileprivate func setDeviceInfo(pushNotificationEnabled: Bool) {
        setDeviceInfoTask = Task { [weak self] in
            let memberLogDeviceModel = MemberLogDeviceModel(
                os: UIDevice.current.systemName,
                brand: "Apple",
                model: UIDevice.modelName,
                pushNotificationEnabled: pushNotificationEnabled
            )
            await self?.client.setDeviceInfo(model: memberLogDeviceModel)
        }
    }

    /// Firebase discards a user id that is set while collection is disabled, and the member usually gives
    /// consent after login, so the user id is applied again once consent is given.
    fileprivate func observeAnalyticsConsent() {
        analyticsConsentCancellable = UserDefaults.standard.publisher(for: \.analyticsConsent)
            .map { $0?.boolValue == true }
            .removeDuplicates()
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self, let userId else { return }
                eventClient.setUserId(userId)
            }
    }
}
