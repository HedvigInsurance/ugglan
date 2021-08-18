//
//  PresentableView.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2021-07-05.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import Presentation
import SwiftUI
import UIKit

public struct PresentableView<P: Presentable>: UIViewControllerRepresentable
where P.Matter: UIViewController, P.Result == Disposable {
	public init(
		presentable: P
	) {
		self.presentable = presentable
	}

	let presentable: P
	let bag = DisposeBag()

	public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

	}

	public func makeCoordinator() {
		return ()
	}

	public func makeUIViewController(context: Context) -> some UIViewController {
		let viewController = presentable.materialize(into: bag)
		return viewController
	}
}
