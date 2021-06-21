//
//  Timeline.swift
//  TestingUtil
//
//  Created by Sam Pettersson on 2021-06-21.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Foundation
import hCore

public struct Timeline<T>: SignalProvider {
	private let entries: [TimelineEntry<T>]

	public var providedSignal: CoreSignal<Plain, T> {
		let initialEntry = entries.first { entry in
			entry.after == 0
		}

		let signal = ReadWriteSignal(initialEntry!.data)

		let bag = DisposeBag()

		bag +=
			entries.filter({ entry in
				entry.after != 0
			})
			.map { entry in
				Signal(after: entry.after)
					.map { _ in
						entry.data
					}
					.bindTo(signal)
			}

		return signal.atOnce().hold(bag).plain()
	}

	init(
		entries: [TimelineEntry<T>]
	) {
		self.entries = entries
	}
}

public struct TimelineEntry<T> {
	let after: TimeInterval
	let data: T

	public init(
		after: TimeInterval,
		data: T
	) {
		self.after = after
		self.data = data
	}
}

@resultBuilder public struct TimelineBuilder<T> {
	public static func buildBlock(_ partialResults: TimelineEntry<T>...) -> Timeline<T> {
		Timeline(entries: partialResults)
	}
}
