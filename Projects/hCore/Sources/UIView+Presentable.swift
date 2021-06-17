//
//  UIView+Presentable.swift
//  hCore
//
//  Created by Sam Pettersson on 2021-04-20.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit

public enum UIViewPresentationOptions {
	case autoRemove
}

extension UIView {
	public func addSubview<P: Presentable>(
		_ presentable: P,
		options: Set<UIViewPresentationOptions> = [],
		configure: @escaping (_ matter: P.Matter, _ result: P.Result) -> Void = { _, _ in () }
	) -> Disposable where P.Matter: UIView, P.Result == Disposable {
		let (view, disposable) = presentable.materialize()

		self.addSubview(view)

		let bag = DisposeBag()
		bag.add(disposable)

		if options.contains(.autoRemove) {
			bag += {
				view.removeFromSuperview()
			}
		}

		configure(view, disposable)

		return bag
	}
}

extension UIStackView {
	public func addArrangedSubview<P: Presentable>(
		_ presentable: P,
		options: Set<UIViewPresentationOptions> = [],
		configure: @escaping (_ matter: P.Matter, _ result: P.Result) -> Void = { _, _ in () }
	) -> Disposable where P.Matter: UIView, P.Result == Disposable {
		let (view, disposable) = presentable.materialize()

		self.addArrangedSubview(view)

		let bag = DisposeBag()
		bag.add(disposable)

		if options.contains(.autoRemove) {
			bag += {
				view.removeFromSuperview()
			}
		}

		configure(view, disposable)

		return bag
	}
}

extension RowView {
	public func append<P: Presentable>(_ presentable: P, options: Set<UIViewPresentationOptions> = []) -> Disposable
	where P.Matter: UIView, P.Result == Disposable {
		let (view, disposable) = presentable.materialize()

		self.append(view)

		let bag = DisposeBag()
		bag.add(disposable)

		if options.contains(.autoRemove) {
			bag += {
				view.removeFromSuperview()
			}
		}

		return bag
	}
}

extension SectionView {
	public func append<P: Presentable>(_ presentable: P, options: Set<UIViewPresentationOptions> = []) -> Disposable
	where P.Matter: UIView, P.Result == Disposable {
		let (view, disposable) = presentable.materialize()

		self.append(view)

		let bag = DisposeBag()
		bag.add(disposable)

		if options.contains(.autoRemove) {
			bag += {
				view.removeFromSuperview()
			}
		}

		return bag
	}
}

extension FormView {
	public func append<P: Presentable>(
		_ presentable: P,
		options: Set<UIViewPresentationOptions> = [],
		configure: @escaping (_ matter: P.Matter, _ result: P.Result) -> Void = { _, _ in () }
	) -> Disposable where P.Matter: UIView, P.Result == Disposable {
		let (view, disposable) = presentable.materialize()

		self.append(view)

		let bag = DisposeBag()
		bag.add(disposable)

		if options.contains(.autoRemove) {
			bag += {
				view.removeFromSuperview()
			}
		}

		configure(view, disposable)

		return bag
	}
}
