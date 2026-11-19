import Foundation
import hCore

public class PowerOfAttorneyClientDemo: PowerOfAttorneyClient {
    private let demoUrl = URL(string: "https://www.hedvig.com")

    public init() {}

    public func getPowerOfAttorneys() async throws -> [PowerOfAttorney] {
        [
            .init(id: "1", name: "Anna Andersson", ssn: "199001011234", level: .full, shareUrl: demoUrl),
            .init(id: "2", name: "Erik Eriksson", ssn: "198505052345", level: .partial, shareUrl: demoUrl),
        ]
    }

    public func getReceivedPowerOfAttorneys() async throws -> [ReceivedPowerOfAttorney] {
        [
            .init(id: "3", memberId: "12345678", name: "Demo Member", level: .full, loginUrl: demoUrl)
        ]
    }

    public func revokePowerOfAttorney(id _: String) async throws {
        try await Task.sleep(for: .seconds(1))
    }

    public func startSigning(
        for _: PowerOfAttorneyUser,
        level _: PowerOfAttorneyLevel
    ) async throws -> PowerOfAttorneySigningSession {
        guard let demoUrl else {
            throw PowerOfAttorneyError.error(message: "Invalid demo url")
        }
        return .init(id: UUID().uuidString, pollUrl: demoUrl, autoStartToken: UUID().uuidString, liveQrCodeData: nil)
    }

    public func observeSigningStatus(pollUrl _: URL) -> AsyncThrowingStream<PowerOfAttorneySigningStatus, Error> {
        let demoUrl = demoUrl
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for index in 0..<3 {
                        continuation.yield(
                            .pending(qrCode: "bankid.demo.\(index).\(UUID().uuidString)", statusText: nil)
                        )
                        try await Task.sleep(for: .seconds(1))
                    }
                    if let demoUrl {
                        continuation.yield(.success(shareUrl: demoUrl))
                    } else {
                        continuation.yield(.failed(message: "Invalid demo url"))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
