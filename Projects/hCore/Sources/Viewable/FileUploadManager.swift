import Foundation

public class FileUploadManager {
    public init() {}
    private static let uploadFolderPath = FileManager.default.temporaryDirectory.appendingPathComponent("uploadedFiles")
    public func getPathForData(for id: String) -> URL {
        FileUploadManager.uploadFolderPath.appendingPathComponent("\(id)")
    }

    public func getPathForThumnailData(for id: String) -> URL {
        FileUploadManager.uploadFolderPath.appendingPathComponent("\(id)-thumb")
    }

    public func resetuploadFilesPath() {
        var isDir: ObjCBool = true
        do {
            if FileManager.default.fileExists(
                atPath: FileUploadManager.uploadFolderPath.relativePath,
                isDirectory: &isDir
            ) {
                let content = try FileManager.default
                    .contentsOfDirectory(atPath: FileUploadManager.uploadFolderPath.relativePath)
                try content.forEach {
                    try FileManager.default.removeItem(
                        atPath: FileUploadManager.uploadFolderPath.appendingPathComponent($0).relativePath
                    )
                }
            } else {
                try FileManager.default.createDirectory(
                    at: FileUploadManager.uploadFolderPath,
                    withIntermediateDirectories: true
                )
            }
        } catch _ {}
    }
}
