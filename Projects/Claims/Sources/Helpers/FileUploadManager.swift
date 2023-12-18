import Foundation
import hCore

class FileUploadManager {
    private static let uploadFolderPath = FileManager.default.temporaryDirectory.appendingPathComponent("uploadedFiles")
    func getPathForData(for id: String, andExtension extension: String) -> URL {
        return FileUploadManager.uploadFolderPath.appendingPathComponent("\(id).\(`extension`)")
    }
    func getPathForThumnailData(for id: String, andExtension extension: String) -> URL {
        return FileUploadManager.uploadFolderPath.appendingPathComponent("\(id)-thumb.\(`extension`)")
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
                try content.forEach({
                    try FileManager.default.removeItem(
                        atPath: FileUploadManager.uploadFolderPath.appendingPathComponent($0).relativePath
                    )
                })
            } else {
                try FileManager.default.createDirectory(
                    at: FileUploadManager.uploadFolderPath,
                    withIntermediateDirectories: true
                )
            }
        } catch let _ {

        }
    }
}
