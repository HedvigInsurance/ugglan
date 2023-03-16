import Foundation

public struct UploadFileResponseModel: Decodable {
    let bucket: String
    let file: FileResponseModel
}

public struct FileResponseModel: Decodable {
    let name: String
    let content: String
    let contentType: String
}
