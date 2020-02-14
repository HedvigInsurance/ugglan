//
//  Stuff.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-23.
//

import Foundation
import Presentation
import UIKit
import Flow
import Form
import Apollo
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
                
                func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
                    print("hello", session)
                    
                    if session.isPaired {
                        print("have an apple watch")
                    }
                    
                    onDone()
                }
                
                func sessionDidBecomeInactive(_ session: WCSession) {
                    
                }
                
                func sessionDidDeactivate(_ session: WCSession) {
                    
                }
                
                
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
        
        bag += formView.append(KeyGearListCollection()).onValue { result in
            switch result {
            case .add:
                viewController.present(AddKeyGearItem(), style: .modally()).onValue { _ in
                    viewController.present(KeyGearItem(name: "test"), style: .default, options: [.largeTitleDisplayMode(.never)])
                }
            case .row:
                viewController.present(KeyGearItem(name: "test"), style: .default, options: [.largeTitleDisplayMode(.never)])
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
