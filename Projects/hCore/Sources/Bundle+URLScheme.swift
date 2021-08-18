import Foundation

extension Bundle {
    public var urlScheme: String? {
        guard let urlTypes = infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
            let urlTypeDictionary = urlTypes.first as? [String: AnyObject],
            let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [AnyObject],
            let externalURLScheme = urlSchemes.first as? String
        else { return nil }
        return externalURLScheme
    }
}
