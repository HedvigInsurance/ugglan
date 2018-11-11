//
//  AppDelegate.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import UIKit
import Katana
import Tempura

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RootInstaller {

    var window: UIWindow?
    var store: Store<AppState>!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        self.store = Store<AppState>(middleware: [], dependencies: DependenciesContainer.self)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        if let dependenciesContainer = self.store!.dependencies as? DependenciesContainer {
            let navigator: Navigator! = dependenciesContainer.navigator
            navigator.start(using: self, in: self.window!, at: Screen.chat)
        }
        
        return true
    }
    
    func installRoot(
        identifier: RouteElementIdentifier,
        context: Any?,
        completion: () -> Void
    ) {
        if identifier == Screen.chat.rawValue {
            let chatViewController = ChatViewController(store: self.store)
            let navigationController = UINavigationController(rootViewController: chatViewController)
            self.window?.rootViewController = navigationController
            completion()
        }
    }
    
}
