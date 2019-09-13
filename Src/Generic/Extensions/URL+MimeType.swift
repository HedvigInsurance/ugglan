//
//  URL+MimeType.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-09-12.
//

import Foundation
import MobileCoreServices

extension URL {
    /// returns the mimeType based on the pathExtension on the URL
    var mimeType: String {
        let pathExtension = self.pathExtension
        let fallback = "application/octet-stream"

        guard let uti = UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension,
            pathExtension as NSString,
            nil
        )?.takeRetainedValue() else {
            return fallback
        }

        guard let mimeType = UTTypeCopyPreferredTagWithClass(
            uti,
            kUTTagClassMIMEType
        )?.takeRetainedValue() else {
            return fallback
        }

        return String(mimeType)
    }
}
