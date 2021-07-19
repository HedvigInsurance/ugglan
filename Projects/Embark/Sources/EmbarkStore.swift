import Flow
import Foundation
import hCore
import hGraphQL

extension String { var floatValue: Float { Float(self) ?? 0 } }

class EmbarkStore {
	var prefill: [String: String] = [:]
	var revisions: [[String: String]] = [[:]]
	var queue: [String: String] = [:]
	var computedValues: [String: String] = [:]

	func setValue(key: String?, value: String?) {
		if let key = key, let value = value {
			guard let arraySymbolRegex = try? NSRegularExpression(pattern: "[\\[\\]]") else { return }
			let keyRange = NSRange(location: 0, length: key.utf16.count)
			let valueRange = NSRange(location: 0, length: value.utf16.count)

			// handling for array based keys and values
			if arraySymbolRegex.firstMatch(in: key, options: [], range: keyRange) != nil,
				arraySymbolRegex.firstMatch(in: value, options: [], range: valueRange) != nil
			{
				var mutableValue = String(value)
				mutableValue.removeFirst()
				mutableValue.removeLast()
				let values = mutableValue.split(separator: ",")

				var mutableKey = String(key)
				mutableKey.removeFirst()
				mutableKey.removeLast()
				mutableKey.split(separator: ",").enumerated()
					.forEach { arg in let (offset, key) = arg
						setValue(key: String(key), value: String(values[offset]))
					}
			} else {
				prefill[key] = value
				queue[key] = value
			}
		}
	}

	func getAllValues() -> [String: String] {
		let mappedComputedValues = computedValues.compactMapValues { value in parseComputedExpression(value) }

		return mappedComputedValues.merging(revisions.last ?? [:], uniquingKeysWith: takeLeft)
	}

	private func parseComputedExpression(_ expression: String) -> String? {
		expression.tokens.expression?.evaluate(store: self)
	}

	private func arrayRegexFor(key: String) -> String {
		return "\(key)\\[[0-9]+\\]$"
	}

	func getValues(key: String, includeQueue: Bool = false) -> [String]? {
		if let computedExpression = computedValues[key] {
			return [parseComputedExpression(computedExpression)].compactMap { $0 }
		}

		if let store = revisions.last {
            let storeWithQueue = includeQueue ? queue.merging(store, uniquingKeysWith: takeLeft) : store
            
			let filteredStore = storeWithQueue.filter { (innerKey, value) in
				innerKey.range(of: arrayRegexFor(key: key), options: .regularExpression) != nil
			}

			if !filteredStore.isEmpty {
				return Array(filteredStore.values)
			}

			if let value = storeWithQueue[key] {
				return [value]
			}
		}

		return nil
	}

    func getValue(key: String, includeQueue: Bool = false) -> String? {
		return getValues(key: key, includeQueue: includeQueue)?.first
	}

	func getValueWithNull(key: String) -> String {
		getValue(key: key) ?? "null"
	}

	func getPrefillValue(key: String) -> String? { prefill[key] }

	func createRevision() {
		guard let store = revisions.last else { return }

		var storeCopy = store

		queue.forEach { key, value in storeCopy[key] = value
			queue.removeValue(forKey: key)
		}

		revisions.append(storeCopy)

		print("COMMITED NEW REVISION:", revisions.last ?? "missing revision")
	}

	func removeLastRevision() {
		if revisions.count > 1 {
			revisions.removeLast()
			print("POPPING LAST REVISION, NEW STORE:", revisions.last ?? "missing revision")
		}
	}

	func passes(expression: GraphQL.BasicExpressionFragment) -> Bool {
		if let binaryExpression = expression.asEmbarkExpressionBinary {
			switch binaryExpression.expressionBinaryType {
			case .equals: return getValue(key: binaryExpression.key) == binaryExpression.value
			case .lessThan:
				if let storeFloat = getValue(key: binaryExpression.key)?.floatValue {
					return storeFloat < binaryExpression.value.floatValue
				}

				return false
			case .lessThanOrEquals:
				if let storeFloat = getValue(key: binaryExpression.key)?.floatValue {
					return storeFloat <= binaryExpression.value.floatValue
				}

				return false
			case .moreThan:
				if let storeFloat = getValue(key: binaryExpression.key)?.floatValue {
					return storeFloat > binaryExpression.value.floatValue
				}

				return false
			case .moreThanOrEquals:
				if let storeFloat = getValue(key: binaryExpression.key)?.floatValue {
					return storeFloat >= binaryExpression.value.floatValue
				}

				return false
			case .notEquals: return getValue(key: binaryExpression.key) != binaryExpression.value
			case .__unknown: return false
			}
		}

		if let unaryExpression = expression.asEmbarkExpressionUnary {
			switch unaryExpression.expressionUnaryType {
			case .always: return true
			case .never: return false
			case .__unknown: return false
			}
		}

		return false
	}

	func passes(expression: GraphQL.ExpressionFragment) -> Bool {
		if let multiple = expression.asEmbarkExpressionMultiple {
			switch multiple.expressionMultipleType {
			case .and:
				return !multiple.subExpressions
					.map { subExpression -> Bool in
						self.passes(expression: subExpression.fragments.basicExpressionFragment)
					}
					.contains(false)
			case .or:
				return !multiple.subExpressions
					.map { subExpression -> Bool in
						self.passes(expression: subExpression.fragments.basicExpressionFragment)
					}
					.contains(true)
			case .__unknown: return false
			}
		}

		return passes(expression: expression.fragments.basicExpressionFragment)
	}

	func passes(expression: GraphQL.MessageFragment.Expression) -> Bool {
		passes(expression: expression.fragments.expressionFragment)
	}

	func shouldRedirectTo(redirect: GraphQL.EmbarkStoryQuery.Data.EmbarkStory.Passage.Redirect) -> String? {
		if let unaryExpression = redirect.fragments.embarkRedirectSingle.asEmbarkRedirectUnaryExpression {
			if unaryExpression.unaryType == .always { return unaryExpression.to }
		}

		if let binaryExpression = redirect.fragments.embarkRedirectSingle.asEmbarkRedirectBinaryExpression {
			switch binaryExpression.binaryType {
			case .equals:
				if getValueWithNull(key: binaryExpression.key) == binaryExpression.value {
					return binaryExpression.to
				}
			case .lessThan:
				if let storeFloat = getValue(key: binaryExpression.key)?.floatValue,
					storeFloat < binaryExpression.value.floatValue
				{
					return binaryExpression.to
				}

			case .lessThanOrEquals:
				if let storeFloat = getValue(key: binaryExpression.key)?.floatValue,
					storeFloat <= binaryExpression.value.floatValue
				{
					return binaryExpression.to
				}
			case .moreThan:
				if let storeFloat = getValue(key: binaryExpression.key)?.floatValue,
					storeFloat > binaryExpression.value.floatValue
				{
					return binaryExpression.to
				}
			case .moreThanOrEquals:
				if let storeFloat = getValue(key: binaryExpression.key)?.floatValue,
					storeFloat >= binaryExpression.value.floatValue
				{
					return binaryExpression.to
				}

			case .notEquals:
				if getValueWithNull(key: binaryExpression.key) != binaryExpression.value {
					return binaryExpression.to
				}
			case .__unknown: break
			}
		}

		if let multipleExpression = redirect.fragments.embarkRedirectFragment
			.asEmbarkRedirectMultipleExpressions
		{
			switch multipleExpression.multipleType {
			case .and:
				if multipleExpression.subExpressions
					.map({ subExpression -> Bool in
						self.passes(expression: subExpression.fragments.expressionFragment)
					})
					.allSatisfy({ passes in passes })
				{
					return multipleExpression.to
				}
			case .or:
				if multipleExpression.subExpressions
					.map({ subExpression -> Bool in
						self.passes(expression: subExpression.fragments.expressionFragment)
					})
					.contains(true)
				{
					return multipleExpression.to
				}
			case .__unknown: break
			}
		}

		return nil
	}
}
