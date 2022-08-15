import Foundation
import Network

public class NetworkReachabability {
    public static let shared = NetworkReachabability()

    let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    public var isReachable: Bool { status == .satisfied }
    public var reachabilityStatusChanged: ((Bool) -> Void)?

    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.reachabilityStatusChanged?(path.status == .satisfied)
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    public func stopMonitoring() {
        monitor.cancel()
    }
}
