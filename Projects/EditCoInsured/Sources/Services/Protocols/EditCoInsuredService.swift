import Foundation

public protocol EditCoInsuredService {
    func get(commitId: String) async throws
}
