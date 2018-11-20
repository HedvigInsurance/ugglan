//
//  MarketingViewController.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-17.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Katana
import PinLayout
import Tempura

class MarketingViewController: ViewController<MarketingView> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func setupInteraction() {
        rootView.didTapOpenChat = {
            self.dispatch(Show(Screen.chat, animated: true))
        }
    }
}
