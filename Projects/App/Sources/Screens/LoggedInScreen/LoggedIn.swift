//
//  LoggedIn.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2021-07-05.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore

struct LoggedIn {
	@Inject var client: ApolloClient
	let didSign: Bool

	init(didSign: Bool = false) { self.didSign = didSign }
}

extension LoggedIn: Presentable {
	func materialize() -> (UIViewController, Disposable) {
		ApplicationState.preserveState(.loggedIn)
		#if targetEnvironment(macCatalyst)
			return (UIHostingController(rootView: SidebarLoggedIn()), NilDisposer())
		#else
			return TabBarLoggedIn(didSign: didSign).materialize()
		#endif
	}
}
