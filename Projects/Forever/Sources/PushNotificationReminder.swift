import Flow
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI

struct PushNotificationReminderView: View {
    @PresentableStore var store: ForeverStore

    public var body: some View {
        hForm {
            hSection {
                VStack(spacing: 16) {
                    Image(uiImage: Asset.pushNotificationReminderIllustration.image)
                    L10n.ReferralsAllowPushNotificationSheet.headline.hText(.title1)
                    L10n.ReferralsAllowPushNotificationSheet.body.hText().foregroundColor(hLabelColor.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .sectionContainerStyle(.transparent).padding(.top, 16)
        }
        .hFormAttachToBottom {
            hButton.LargeButtonFilled {
                // Ask for push notifications
                print("Ask for notifs")
                store.send(.askForPushNotifications)
            } content: {
                L10n.ReferralsAllowPushNotificationSheet.Allow.button.hText()
            }
            .padding()
        }
        .navigationBarItems(
            trailing: Button(action: {
                // Skip
                print("Skip for now")
            }) {
                L10n.NavBar.skip.hText().foregroundColor(Color(.brand(.destructive)))
            }
        )
    }
}

struct PushNotificationReminder {}

extension PushNotificationReminder: Conditional, Presentable {
    enum PushNotificationReminderError: Error {
        case skipped
        case failed
    }

    func condition() -> Bool { !UIApplication.shared.isRegisteredForRemoteNotifications }

    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let skipBarButton = UIBarButtonItem(title: L10n.NavBar.skip, style: .destructive)
        viewController.navigationItem.rightBarButtonItem = skipBarButton

        let imageTextAction = ImageTextAction<Void>(
            image: .init(image: Asset.pushNotificationReminderIllustration.image),
            title: L10n.ReferralsAllowPushNotificationSheet.headline,
            body: L10n.ReferralsAllowPushNotificationSheet.body,
            actions: [
                (
                    (),
                    Button(
                        title: L10n.ReferralsAllowPushNotificationSheet.Allow.button,
                        type: .standard(
                            backgroundColor: .brand(.primaryButtonBackgroundColor),
                            textColor: .brand(.primaryButtonTextColor)
                        )
                    )
                )
            ],
            showLogo: false
        )

        return (
            viewController,
            Future { completion in
                bag += viewController.install(imageTextAction)
                    .onValue {
                        let center = UNUserNotificationCenter.current()
                        center.requestAuthorization(options: [.alert, .sound, .badge]) {
                            _,
                            error in
                            DispatchQueue.main.async {
                                if error != nil {
                                    completion(
                                        .failure(
                                            PushNotificationReminderError
                                                .failed
                                        )
                                    )
                                } else {
                                    completion(.success)
                                }
                            }
                        }
                    }

                bag += skipBarButton.onValue {
                    completion(.failure(PushNotificationReminderError.skipped))
                }

                return DelayedDisposer(bag, delay: 2)
            }
        )
    }
}
