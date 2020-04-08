//
//  SceneDelegate.swift
//  Ugglan
//
//  Created by sam on 8.4.20.
//  Copyright © 2020 Hedvig. All rights reserved.
//

import Foundation
import UIKit
import Flow

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

var window: UIWindow?
    let bag = DisposeBag()

func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)
{
    if let windowScene = scene as? UIWindowScene {

        let window = UIWindow(windowScene: windowScene)
        
        bag += ApplicationState.presentRootViewController(window)

        self.window = window
        window.makeKeyAndVisible()
    }
}

}
