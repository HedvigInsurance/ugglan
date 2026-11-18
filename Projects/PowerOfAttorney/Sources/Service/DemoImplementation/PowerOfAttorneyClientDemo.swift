import Foundation

public class PowerOfAttorneyClientDemo: PowerOfAttorneyClient {
    private let demoUrl = URL(string: "https://www.hedvig.com")
    private let demoUsers: [PowerOfAttorneyUser] = [
        .init(id: "1", firstName: "Anna", lastName: "Andersson", ssn: "199001011234"),
        .init(id: "2", firstName: "Erik", lastName: "Eriksson", ssn: "198505052345"),
        .init(id: "3", firstName: "Maja", lastName: "Svensson", ssn: "201506151234"),
        .init(id: "4", firstName: "Lars", lastName: "Nilsson", ssn: "197803034567"),
        .init(id: "5", firstName: "Sofia", lastName: "Johansson", ssn: "199512125678"),
        .init(id: "6", firstName: "Oskar", lastName: "Lindberg", ssn: "200208086789"),
    ]

    public init() {}

    public func getPowerOfAttorneys() async throws -> [PowerOfAttorney] {
        [
            .init(
                id: "1",
                name: demoUsers[0].fullName,
                ssn: demoUsers[0].ssn ?? "",
                status: .active,
                level: .full,
                shareUrl: demoUrl
            ),
            .init(
                id: "2",
                name: demoUsers[1].fullName,
                ssn: demoUsers[1].ssn ?? "",
                status: .revoked,
                level: .partial,
                shareUrl: demoUrl
            ),
        ]
    }

    public func getCoInsured() async throws -> [PowerOfAttorneyUser] {
        demoUsers
    }

    public func getUser(personalNumber: String) async throws -> PowerOfAttorneyUser {
        try await Task.sleep(for: .seconds(1))
        return .init(id: personalNumber, firstName: "Karin", lastName: "Berg", ssn: personalNumber)
    }

    public func startSigning(
        for _: PowerOfAttorneyUser,
        level _: PowerOfAttorney.Level
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
