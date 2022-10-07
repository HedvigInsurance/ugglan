import Foundation

extension String {
    public var isValidURL: Bool {
        let urlRegEx =
            "((?:http|https)://)?(?:[\\w\\d\\-_]+\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: self)
    }
}
