import Apollo
import Flow
import Form
import hCore
import hCoreUI
import hGraphQL
import Presentation
import SwiftUI
import UIKit

struct About {
    @Inject var client: ApolloClient
    let state: State

    enum State {
        case onboarding, loggedIn
    }

    init(state: State) {
        self.state = state
    }
}

extension About: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = L10n.aboutScreenTitle

        let bag = DisposeBag()

        let form = FormView()

        if state == .onboarding {
            form.appendSpacing(.inbetween)

            let loginSection = form.appendSection(
                headerView: nil,
                footerView: nil
            )

            let loginRow = ButtonRow(
                text: L10n.settingsLoginRow,
                style: .brand(.headline(color: .link))
            )
            bag += loginSection.append(loginRow)

            bag += loginRow.onSelect.onValue { _ in
                viewController.present(
                    BankIDLogin(),
                    style: .detented(.medium, .large),
                    options: [.allowSwipeDismissAlways, .defaults]
                )
            }

            bag += form.append(Spacing(height: 20))
        }

        let versionSection = form.appendSection(
            headerView: nil,
            footerView: nil
        )

        let versionRow = VersionRow()
        bag += versionSection.append(versionRow) { versionRowView in
            let tapGestureRecongnizer = UITapGestureRecognizer()
            tapGestureRecongnizer.numberOfTapsRequired = 2

            versionRowView.viewRepresentation.addGestureRecognizer(tapGestureRecongnizer)

            bag += tapGestureRecongnizer.signal(forState: .recognized).onValue { _ in
                if #available(iOS 13, *) {
                    viewController.present(
                        UIHostingController(rootView: Debug()),
                        style: .detented(.medium, .large),
                        options: []
                    )
                }
            }
        }

        let memberIdRow = MemberIdRow()
        bag += versionSection.append(memberIdRow)

        if state == .loggedIn {
            let activatePushNotificationsRow = ButtonRow(
                text: L10n.aboutPushRow,
                style: .brand(.headline(color: .link))
            )

            bag += versionSection.append(activatePushNotificationsRow)

            let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications

            if !isRegisteredForRemoteNotifications {
                activatePushNotificationsRow.isHiddenSignal.value = false

                bag += activatePushNotificationsRow.onSelect.onValueDisposePrevious { _ in
                    let register = PushNotificationsRegister(
                        title: L10n.pushNotificationsAlertTitle,
                        message: "",
                        forceAsk: true
                    )

                    return viewController.present(register).onResult { result in
                        switch result {
                        case .success: activatePushNotificationsRow.isHiddenSignal.value = true
                        case .failure:
                            break
                        }
                    }.disposable
                }
            } else {
                activatePushNotificationsRow.isHiddenSignal.value = true
            }

            let showWelcome = ButtonRow(
                text: L10n.aboutShowIntroRow,
                style: .brand(.headline(color: .link))
            )
            bag += versionSection.append(showWelcome)

            bag += showWelcome.onSelect.onValue { _ in
                viewController.present(WelcomePager())
            }
        }

        bag += form.append(Spacing(height: 20))

        let otherSection = form.appendSection(
            headerView: nil,
            footerView: nil
        )

        let languageRow = LanguageRow(
            presentingViewController: viewController
        )

        bag += otherSection.append(languageRow) { row in
            bag += viewController.registerForPreviewing(
                sourceView: row.viewRepresentation,
                previewable: languageRow
            )
        }

        bag += form.append(Spacing(height: 15))

        let year = Calendar.current.component(.year, from: Date())

        let footerView = UILabel(
            value: "© Hedvig AB - \(year)",
            style: TextStyle.brand(.footnote(color: .primary)).centerAligned
        )
        footerView.textAlignment = .center

        form.append(footerView)

        bag += viewController.install(form)

        return (viewController, bag)
    }
}
