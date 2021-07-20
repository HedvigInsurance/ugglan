import Flow
import Foundation
import UIKit
import hCore
import hGraphQL

public enum ExternalRedirect {
	case mailingList
	case offer(ids: [String])
}

public class EmbarkState {
	var store = EmbarkStore()
	var edgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
	let storySignal = ReadWriteSignal<GraphQL.EmbarkStoryQuery.Data.EmbarkStory?>(nil)
	let startPassageIDSignal = ReadWriteSignal<String?>(nil)
	let passagesSignal = ReadWriteSignal<[GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage]>([])
	let currentPassageSignal = ReadWriteSignal<GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage?>(nil)
	let passageHistorySignal = ReadWriteSignal<[GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage]>([])
	let externalRedirectSignal = ReadWriteSignal<ExternalRedirect?>(nil)
	let bag = DisposeBag()

	public init() { defer { startTracking() } }

	enum AnimationDirection {
		case forwards
		case backwards
	}

	let animationDirectionSignal = ReadWriteSignal<AnimationDirection>(.forwards)
	var canGoBackSignal: ReadSignal<Bool> { passageHistorySignal.map { !$0.isEmpty } }

	var passageNameSignal: ReadSignal<String?> { currentPassageSignal.map { $0?.name } }

	var passageTooltipsSignal: ReadSignal<[Tooltip]> { currentPassageSignal.map { $0?.tooltips ?? [] } }

	func restart() {
		animationDirectionSignal.value = .backwards
		currentPassageSignal.value = passagesSignal.value.first(where: { passage -> Bool in
			passage.id == startPassageIDSignal.value
		})
		store.computedValues =
			storySignal.value?.computedStoreValues?
			.reduce([:]) { (prev, computedValue) -> [String: String] in
				var computedValues: [String: String] = prev
				computedValues[computedValue.key] = computedValue.value
				return computedValues
			} ?? [:]
		passageHistorySignal.value = []
		store = EmbarkStore()
	}

	func startTracking() {
		bag += currentPassageSignal.readOnly().compactMap { $0?.tracks }
			.onValue(on: .background) { tracks in
				tracks.forEach { track in
					track.trackingEvent(storeValues: self.store.getAllValues()).send()
				}
			}
	}

	func goBack() {
		trackGoBack()
		animationDirectionSignal.value = .backwards
		currentPassageSignal.value = passageHistorySignal.value.last
		var history = passageHistorySignal.value
		history.removeLast()
		passageHistorySignal.value = history
		store.removeLastRevision()
	}

	func goTo(passageName: String, pushHistoryEntry: Bool = true) {
		animationDirectionSignal.value = .forwards
		store.createRevision()

		if let newPassage = passagesSignal.value.first(where: { passage -> Bool in passage.name == passageName }
		) {
			let resultingPassage = handleRedirects(passage: newPassage) ?? newPassage

			if let resultingPassage = currentPassageSignal.value, pushHistoryEntry {
				passageHistorySignal.value.append(resultingPassage)
			}

			if let externalRedirect = resultingPassage.externalRedirect?.data.location {
				EmbarkTrackingEvent(
					title: "External Redirect",
					properties: ["location": externalRedirect.rawValue]
				)
				.send()
				switch externalRedirect {
				case .mailingList: externalRedirectSignal.value = .mailingList
				case .offer:
					externalRedirectSignal.value = .offer(
						ids: [store.getValue(key: "quoteId")].compactMap { $0 }
					)
				case .__unknown: fatalError("Can't external redirect to location")
                    #warning("Must be handled")
                case .close:
                    ()
                case .chat:
                    ()
                }
			} else if let offerRedirectKeys = resultingPassage.offerRedirect?.data.keys.compactMap({ $0 }) {
				EmbarkTrackingEvent(title: "Offer Redirect", properties: [:]).send()
				externalRedirectSignal.value = .offer(
					ids: offerRedirectKeys.compactMap { key in store.getValue(key: key) }
				)
			} else {
				currentPassageSignal.value = resultingPassage
			}
		}
	}

	private func handleRedirects(
		passage: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage
	) -> GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage? {
		passage.redirects.map { redirect in store.shouldRedirectTo(redirect: redirect) }
			.map { redirectTo in
				passagesSignal.value.first(where: { passage -> Bool in passage.name == redirectTo })
			}
			.compactMap { $0 }.first
	}

	private var totalStepsSignal = ReadWriteSignal<Int?>(nil)

	var progressSignal: ReadSignal<Float> {
		func findMaxDepth(passageName: String, previousDepth: Int = 0) -> Int {
			guard let passage = passagesSignal.value.first(where: { $0.name == passageName }) else {
				return 0
			}

			let links = passage.allLinks.map { $0.name }

			if links.isEmpty { return previousDepth }

			return
				links.map { linkPassageName in
					findMaxDepth(passageName: linkPassageName, previousDepth: previousDepth + 1)
				}
				.reduce(0) { result, current in max(result, current) }
		}

		return
			currentPassageSignal.map { currentPassage in
				guard let currentPassage = currentPassage else { return 0 }

				let passagesLeft = currentPassage.allLinks.map { findMaxDepth(passageName: $0.name) }
					.reduce(0) { result, current in max(result, current) }

				if self.totalStepsSignal.value == nil { self.totalStepsSignal.value = passagesLeft }

				guard let totalSteps = self.totalStepsSignal.value else { return 0 }

				return (Float(totalSteps - passagesLeft) / Float(totalSteps))
			}
			.latestTwo()
			.delay { lhs, rhs -> TimeInterval? in if lhs > rhs { return 0 }

				return 0.25
			}
			.map { _, rhs in rhs }.readable(initial: 0)
	}
}
