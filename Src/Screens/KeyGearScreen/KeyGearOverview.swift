//
//  Stuff.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-23.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import WatchConnectivity

struct KeyGearOverview {
    @Inject var client: ApolloClient

    func autoAddDevices() {
        if WCSession.isSupported() {
            let bag = DisposeBag()
            let session = WCSession.default
            let coordinator = Coordinator { [unowned bag] in
                bag.dispose()
            }
            bag.hold(coordinator)
            session.delegate = coordinator

            session.activate()

            class Coordinator: NSObject, WCSessionDelegate {
                let onDone: () -> Void

                init(onDone: @escaping () -> Void) {
                    self.onDone = onDone
                }

                func session(_ session: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {
                    if session.isPaired {
                        print("have an apple watch")
                    }

                    onDone()
                }

                func sessionDidBecomeInactive(_: WCSession) {}

                func sessionDidDeactivate(_: WCSession) {}
            }
        }
    }
}

extension KeyGearOverview: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.title = String(key: .KEY_GEAR_TAB_TITLE)

        autoAddDevices()

        let formView = FormView()

        bag += formView.prepend(TabHeader(
            image: Asset.keyGearOverviewHeader.image,
            title: String(key: .KEY_GEAR_START_EMPTY_HEADLINE),
            description: String(key: .KEY_GEAR_START_EMPTY_BODY)
        ))
        
        let button = Button(title: "PressTest", type: .standard(backgroundColor: .transparent, textColor: .purple))
        bag += formView.append(button)
        
        bag += button.onTapSignal.onValue({ _ in
            let presentable = PlaceholderVC().withCloseButton
            viewController.present(presentable, style: .modal)
        })

        bag += formView.append(KeyGearListCollection()).onValue { result in
            switch result {
            case .add:
                viewController.present(AddKeyGearItem(), style: .modally()).onValue { id in
                    viewController.present(KeyGearItem(id: id), style: .default, options: [.largeTitleDisplayMode(.never)])
                }
            case let .row(id):
                viewController.present(KeyGearItem(id: id), style: .default, options: [.largeTitleDisplayMode(.never)])
            }
        }

        let refreshControl = UIRefreshControl()
        bag += client.refetchOnRefresh(query: KeyGearItemsQuery(), refreshControl: refreshControl)

        bag += viewController.install(formView) { scrollView in
            scrollView.refreshControl = refreshControl
        }

        return (viewController, bag)
    }
}

extension KeyGearOverview: Tabable {
    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(
            title: String(key: .KEY_GEAR_TAB_TITLE),
            image: Asset.keyGearTabIcon.image,
            selectedImage: Asset.keyGearTabIcon.image
        )
    }
}
