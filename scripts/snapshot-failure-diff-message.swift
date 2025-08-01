#!/usr/bin/env swift

import Foundation

let fileManager = FileManager()

let cwd = fileManager.currentDirectoryPath
let failureDir = "/tmp/__SnapshotFailures__"

if !fileManager.fileExists(atPath: failureDir) { exit(0) }

let failureDirs = try fileManager.contentsOfDirectory(at: URL(string: failureDir)!, includingPropertiesForKeys: nil)

let allFailures =
    failureDirs.map { dir -> [URL]? in
        let failures = try? fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        return failures
    }
    .compactMap { $0 }.flatMap { $0 }

struct ImgurResponse: Codable {
    let data: ImgurData

    struct ImgurData: Codable { let link: String }
}

func uploadFile(_ file: URL, onCompletion: @escaping (_ link: String) -> Void) {
    var request = URLRequest(url: URL(string: "https://api.imgur.com/3/image")!)
    request.allHTTPHeaderFields = ["Authorization": "Client-ID e1dab8f4e0cf6f2"]
    request.httpMethod = "POST"
    let task = URLSession.shared.uploadTask(with: request, fromFile: file) { data, _, _ in
        guard let data = data else { exit(1) }
        guard let response = try? JSONDecoder().decode(ImgurResponse.self, from: data) else { exit(1) }

        onCompletion(response.data.link)
    }
    task.resume()
}

let actualAndReference =
    allFailures.map { failure -> (failure: URL, reference: URL) in
        let enumerator = FileManager.default.enumerator(atPath: cwd)
        let filePaths = enumerator?.allObjects as! [String]
        let reference = filePaths.first { $0.contains(failure.lastPathComponent) }
        return (failure: failure, reference: URL(string: reference!)!)
    }
    .map { failure, reference -> (failure: String, reference: String) in
        var failureImageLink: String = ""
        var referenceImageLink: String = ""

        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        uploadFile(failure) { failureLink in
            failureImageLink = failureLink
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        uploadFile(reference) { referenceLink in
            referenceImageLink = referenceLink
            dispatchGroup.leave()
        }

        dispatchGroup.wait()

        return (failure: failureImageLink, reference: referenceImageLink)
    }

let githubComment = """
        WorkspaceTests found a missmatch in screenshots:

        Failure  |  Reference
        :-------------------------:|:-------------------------:
        \(actualAndReference.map { "![](\($0.failure)) | ![](\($0.reference))" }.joined(separator: "\n"))

        If you changed styling which expects this outcome run the `WorkspaceTests Record` scheme and commit the updated reference screenshots.
    """

print(githubComment)
