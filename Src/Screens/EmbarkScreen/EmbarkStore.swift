//
//  EmbarkStore.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-16.
//

import Foundation
import Flow

class EmbarkStore {
    var store: [String: String] = [:]
    
    func setValue(key: String?, value: String?) {
        if let key = key, let value = value {
            let arraySymbolRegex = try! NSRegularExpression(pattern: "[\\[\\]]")
            let keyRange = NSRange(location: 0, length: key.utf16.count)
            let valueRange = NSRange(location: 0, length: value.utf16.count)
              
            // handling for array based keys and values
            if
                arraySymbolRegex.firstMatch(in: key, options: [], range: keyRange) != nil &&
                arraySymbolRegex.firstMatch(in: value, options: [], range: valueRange) != nil {
                
                var mutableValue = String(value)
                mutableValue.removeFirst()
                mutableValue.removeLast()
                let values = mutableValue.split(separator: ",")
                                
                var mutableKey = String(key)
                mutableKey.removeFirst()
                mutableKey.removeLast()
                mutableKey.split(separator: ",").enumerated().forEach { (arg) in
                    let (offset, key) = arg
                    setValue(key: String(key), value: String(values[offset]))
                }
            } else {
                store[key] = value
            }
        }
        
        print("STORE:", store)
    }
    
    func passes(expression: BasicExpressionFragment) -> Bool {
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
            case .__unknown(_):
                return false
            }
        }
        
        if let unaryExpression = expression.asEmbarkExpressionUnary {
            switch unaryExpression.expressionUnaryType {
            case .always:
                return true
            case .never:
                return false
            case .__unknown(_):
                return false
            }
        }
        
        return false
    }
    
    func passes(expression: EmbarkStoryQuery.Data.EmbarkStory.Passage.Message.Expression) -> Bool {
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
            case .__unknown(_):
                return false
            }
        }
        
        return passes(expression: expression.fragments.expressionFragment.fragments.basicExpressionFragment)
    }
}
