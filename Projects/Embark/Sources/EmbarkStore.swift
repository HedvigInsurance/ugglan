//
//  EmbarkStore.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-16.
//

import Flow
import Foundation

class EmbarkStore {
    var revisions: [[String: String]] = [[:]]
    var queue: [String: String] = [:]

    func setValue(key: String?, value: String?) {
        if let key = key, let value = value {
            guard let arraySymbolRegex = try? NSRegularExpression(pattern: "[\\[\\]]") else {
                return
            }
            let keyRange = NSRange(location: 0, length: key.utf16.count)
            let valueRange = NSRange(location: 0, length: value.utf16.count)

            // handling for array based keys and values
            if
                arraySymbolRegex.firstMatch(in: key, options: [], range: keyRange) != nil,
                arraySymbolRegex.firstMatch(in: value, options: [], range: valueRange) != nil {
                var mutableValue = String(value)
                mutableValue.removeFirst()
                mutableValue.removeLast()
                let values = mutableValue.split(separator: ",")

                var mutableKey = String(key)
                mutableKey.removeFirst()
                mutableKey.removeLast()
                mutableKey.split(separator: ",").enumerated().forEach { arg in
                    let (offset, key) = arg
                    setValue(key: String(key), value: String(values[offset]))
                }
            } else {
                queue[key] = value
            }
        }
    }

    func getValue(key: String) -> String? {
        if let store = revisions.last {
            return store[key]
        }

        return nil
    }

    func createRevision() {
        guard let store = revisions.last else {
            return
        }

        var storeCopy = store

        queue.forEach { key, value in
            storeCopy[key] = value
            queue.removeValue(forKey: key)
        }

        revisions.append(storeCopy)

        print("COMMITED NEW REVISION:", revisions.last ?? "missing revision")
    }

    func removeLastRevision() {
        revisions.removeLast()
        print("POPPING LAST REVISION, NEW STORE:", revisions.last ?? "missing revision")
    }

    func passes(expression: BasicExpressionFragment) -> Bool {
        guard let store = revisions.last else {
            return false
        }

        if let binaryExpression = expression.asEmbarkExpressionBinary {
            switch binaryExpression.expressionBinaryType {
            case .equals:
                return store[binaryExpression.key] == binaryExpression.value
            case .lessThan:
                if
                    let storeFloat = Float(store[binaryExpression.key] ?? ""),
                    let expressionFloat = Float(binaryExpression.value) {
                    return storeFloat < expressionFloat
                }

                return false
            case .lessThanOrEquals:
                if
                    let storeFloat = Float(store[binaryExpression.key] ?? ""),
                    let expressionFloat = Float(binaryExpression.value) {
                    return storeFloat <= expressionFloat
                }

                return false
            case .moreThan:
                if
                    let storeFloat = Float(store[binaryExpression.key] ?? ""),
                    let expressionFloat = Float(binaryExpression.value) {
                    return storeFloat > expressionFloat
                }

                return false
            case .moreThanOrEquals:
                if
                    let storeFloat = Float(store[binaryExpression.key] ?? ""),
                    let expressionFloat = Float(binaryExpression.value) {
                    return storeFloat >= expressionFloat
                }

                return false
            case .notEquals:
                return store[binaryExpression.key] != binaryExpression.value
            case .__unknown:
                return false
            }
        }

        if let unaryExpression = expression.asEmbarkExpressionUnary {
            switch unaryExpression.expressionUnaryType {
            case .always:
                return true
            case .never:
                return false
            case .__unknown:
                return false
            }
        }

        return false
    }

    func passes(expression: MessageFragment.Expression) -> Bool {
        if let multiple = expression.fragments.expressionFragment.asEmbarkExpressionMultiple {
            switch multiple.expressionMultipleType {
            case .and:
                return !multiple.subExpressions.map { subExpression -> Bool in
                    self.passes(expression: subExpression.fragments.basicExpressionFragment)
                }.contains(false)
            case .or:
                return !multiple.subExpressions.map { subExpression -> Bool in
                    self.passes(expression: subExpression.fragments.basicExpressionFragment)
                }.contains(true)
            case .__unknown:
                return false
            }
        }

        return passes(expression: expression.fragments.expressionFragment.fragments.basicExpressionFragment)
    }
}
