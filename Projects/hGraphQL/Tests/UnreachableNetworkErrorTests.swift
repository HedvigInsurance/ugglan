import Foundation
import Testing

@testable import hGraphQL

final class UnreachableNetworkErrorTests {
    private enum NotAURLError: Error {
        case somethingWentWrong
    }

    // The codes the device raises before the request ever reached a server. Everything else has to stay an
    // error, otherwise a broken backend or a bad certificate is downgraded to a warning nobody monitors.
    @Test(
        arguments: [
            NSURLErrorNotConnectedToInternet,
            NSURLErrorNetworkConnectionLost,
            NSURLErrorCannotFindHost,
            NSURLErrorDNSLookupFailed,
            NSURLErrorInternationalRoamingOff,
            NSURLErrorDataNotAllowed,
            NSURLErrorCallIsActive,
        ]
    )
    func isUnreachableNetworkTrueForOfflineNSErrorCodes(code: Int) {
        #expect(NSError(domain: NSURLErrorDomain, code: code, userInfo: nil).isUnreachableNetwork)
    }

    // URLSession hands Apollo a URLError, not an NSError, so the bridged form has to classify the same way.
    @Test(
        arguments: [
            URLError.Code.notConnectedToInternet,
            .networkConnectionLost,
            .cannotFindHost,
            .dnsLookupFailed,
            .internationalRoamingOff,
            .dataNotAllowed,
            .callIsActive,
        ]
    )
    func isUnreachableNetworkTrueForOfflineURLErrors(code: URLError.Code) {
        #expect(URLError(code).isUnreachableNetwork)
    }

    // -1001 and -1004 mean the host answered or was found but the exchange failed, -1200/-1202 mean TLS
    // rejected it. All four are deliberately excluded so backend and certificate problems stay errors.
    @Test(
        arguments: [
            NSURLErrorTimedOut,
            NSURLErrorCannotConnectToHost,
            NSURLErrorSecureConnectionFailed,
            NSURLErrorServerCertificateUntrusted,
        ]
    )
    func isUnreachableNetworkFalseForNSErrorCodesThatReachedTheServer(code: Int) {
        #expect(NSError(domain: NSURLErrorDomain, code: code, userInfo: nil).isUnreachableNetwork == false)
    }

    @Test(
        arguments: [
            URLError.Code.timedOut,
            .cannotConnectToHost,
            .secureConnectionFailed,
            .serverCertificateUntrusted,
        ]
    )
    func isUnreachableNetworkFalseForURLErrorsThatReachedTheServer(code: URLError.Code) {
        #expect(URLError(code).isUnreachableNetwork == false)
    }

    // Pins the numbers the exclusion is argued about in review, so a renamed constant can't change the set.
    @Test
    func excludedCodesMatchTheirDocumentedRawValues() {
        #expect(URLError.Code.timedOut.rawValue == -1001)
        #expect(URLError.Code.cannotConnectToHost.rawValue == -1004)
        #expect(URLError.Code.secureConnectionFailed.rawValue == -1200)
        #expect(URLError.Code.serverCertificateUntrusted.rawValue == -1202)
    }

    // The domain guard is the only thing stopping an unrelated error that happens to carry -1009 from being
    // classified as offline.
    @Test(arguments: [NSCocoaErrorDomain, NSPOSIXErrorDomain, "com.hedvig.test"])
    func isUnreachableNetworkFalseForTheSameCodeInAnotherDomain(domain: String) {
        let error = NSError(domain: domain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)

        #expect(error.isUnreachableNetwork == false)
    }

    @Test
    func isUnreachableNetworkFalseForACustomSwiftError() {
        #expect(NotAURLError.somethingWentWrong.isUnreachableNetwork == false)
    }

    @Test
    func isUnreachableNetworkFalseForAuthErrors() {
        #expect(AuthError.refreshTokenExpired.isUnreachableNetwork == false)
        #expect(AuthError.refreshFailed.isUnreachableNetwork == false)
        #expect(AuthError.networkIssue.isUnreachableNetwork == false)
    }

    @Test
    func isUnreachableNetworkFalseForGraphQLErrorCases() {
        #expect(GraphQLError.graphQLError(errors: []).isUnreachableNetwork == false)
        #expect(GraphQLError.otherError(error: NotAURLError.somethingWentWrong).isUnreachableNetwork == false)
    }
}
