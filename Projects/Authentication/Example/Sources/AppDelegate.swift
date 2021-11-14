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
            MutationMock(GraphQL.VerifyLoginOtpAttemptMutation.self, duration: 2) { _ in
                .init(loginVerifyOtpAttempt: .makeVerifyOtpLoginAttemptSuccess(accessToken: ""))
            }

            MutationMock(GraphQL.CreateLoginOtpAttemptMutation.self, duration: 2) { _ in
                .init(loginCreateOtpAttempt: UUID().uuidString)
            }
        }

        return true
    }
}
