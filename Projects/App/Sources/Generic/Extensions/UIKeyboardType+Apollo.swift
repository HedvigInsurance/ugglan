import Apollo
import Foundation
import hGraphQL
import UIKit

extension UIKeyboardType {
	static func from(_ keyboardType: GraphQL.KeyboardType?) -> UIKeyboardType? {
		guard let keyboardType = keyboardType else { return nil }

		switch keyboardType {
		case .default: return .default
		case .email: return .emailAddress
		case .decimalpad: return .decimalPad
		case .numberpad: return .numberPad
		case .numeric: return .numeric
		case .phone: return .phonePad
		case .__unknown: return .default
		}
	}
}
