import Foundation

public struct UploadFileResponseModel: Decodable, Sendable {
    public let audioUrl: String

    public init(audioUrl: String) {
        self.audioUrl = audioUrl
    }
}
