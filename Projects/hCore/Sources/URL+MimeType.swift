import Foundation
import MobileCoreServices
import UniformTypeIdentifiers

public extension URL {
    /// returns the mimeType based on the pathExtension on the URL
    var mimeType: String {
        let pathExtension = self.pathExtension
        let fallback = "application/octet-stream"
        guard let mimeType = UTType(filenameExtension: pathExtension)?.preferredMIMEType else { return fallback }
        return mimeType
    }
}
