import Foundation

public struct UploadFile {
    public let data: Data
    public let name: String
    public let mimeType: String

    public init(
        data: Data,
        name: String,
        mimeType: String
    ) {
        self.data = data
        self.name = name
        self.mimeType = mimeType
    }
}
