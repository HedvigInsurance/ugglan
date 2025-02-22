import Foundation
import MobileCoreServices
import UniformTypeIdentifiers

extension URL {
    /// returns the mimeType based on the pathExtension on the URL
    public var mimeType: String {
        let pathExtension = self.pathExtension
        let fallback = "application/octet-stream"
        guard let mimeType = UTType.init(filenameExtension: pathExtension)?.preferredMIMEType else { return fallback }
        return mimeType
    }
}
