import Foundation

extension Date {
	var localDateString: String? {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter.string(from: self)
	}
}
