import Foundation
import MobileCoreServices

extension URL {
    /// returns the mimeType based on the pathExtension on the URL
    public var mimeType: String {
        let pathExtension = self.pathExtension
        let fallback = "application/octet-stream"

        guard
            let uti = UTTypeCreatePreferredIdentifierForTag(
                kUTTagClassFilenameExtension,
                pathExtension as NSString,
                nil
            )?
            .takeRetainedValue()
        else { return fallback }

        guard let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue()
        else { return fallback }

        return String(mimeType)
    }
}
