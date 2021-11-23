import Apollo
import ExampleUtil
import Flow
import Form
import Foundation
import TestingUtil
import UIKit
import hCoreUI
import hGraphQL

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let bag = DisposeBag()

    internal func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        application.setup()

        ApolloClient.createMock {
            MutationMock(GraphQL.VerifyLoginOtpAttemptMutation.self, duration: 2) { operation in
                if operation.otp == "000000" {
                    return .init(loginVerifyOtpAttempt: .makeVerifyOtpLoginAttemptError(errorCode: "fail"))
                } else {
                    return .init(loginVerifyOtpAttempt: .makeVerifyOtpLoginAttemptSuccess(accessToken: ""))
                }
            }

            MutationMock(GraphQL.CreateLoginOtpAttemptMutation.self, duration: 2) { _ in
                .init(loginCreateOtpAttempt: UUID().uuidString)
            }

            MutationMock(GraphQL.ResendLoginOtpMutation.self, duration: 2) { _ in
                .init(loginResendOtp: UUID().uuidString)
            }
        }

        return true
    }
}
