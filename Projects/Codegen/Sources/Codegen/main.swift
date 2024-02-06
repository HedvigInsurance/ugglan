import ApolloCodegenLib
import ArgumentParser
import Foundation

//@main
//struct CustomCodegenScript: AsyncParsableCommand {
//    func run() async throws {

let filePath = "file:///Users/juliaandersson/ugglan/Projects/Codegen/Sources/Codegen/" /* TODO: CHANGE */

let parentFolderOfScriptFile = URL(string: filePath)
let sourceRootURL = parentFolderOfScriptFile?.deletingLastPathComponent().deletingLastPathComponent()
    .deletingLastPathComponent()

let cliFolderURL = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first!
    .appendingPathComponent("Codegen").appendingPathComponent("ApolloCLI")

try FileManager.default.createDirectory(at: cliFolderURL, withIntermediateDirectories: true, attributes: nil)

let endpoints = ["octopus": URL(string: "https://apollo-router.dev.hedvigit.com/")!]

// endless loop
func findAllGraphQLFolders(basePath: String = sourceRootURL?.path ?? "") -> [URL] {
    guard let dirs = try? FileManager.default.contentsOfDirectory(atPath: basePath) else { return [] }

    let ownDirs = dirs.filter { $0 == "GraphQL" }
        .map { URL(string: "file://\(basePath)/\($0)") }
        .compactMap { $0 }

    let nestedDirs = dirs.compactMap { $0 }
        .map { val -> [URL] in findAllGraphQLFolders(basePath: "\(basePath)/\(val)") }
        .flatMap { $0 }
        .filter { !$0.absoluteString.contains("Derived") }

    return [ownDirs, nestedDirs].flatMap { $0 }
}

endpoints.forEach { name, endpoint in
    let downloadConfiguration = ApolloSchemaDownloadConfiguration(
        using: .introspection(endpointURL: endpoint),
        outputPath: cliFolderURL.path
    )

    Task {
        try await ApolloSchemaDownloader.fetch(configuration: downloadConfiguration)
    }

    let sourceUrls = findAllGraphQLFolders()

    sourceUrls.forEach { sourceUrl in
        let sourceUrl = sourceUrl.appendingPathComponent(name.capitalized)

        guard ApolloFileManager.default.doesDirectoryExist(atPath: sourceUrl.path) else {
            return
        }

        let baseFolderUrl =
            sourceUrl
            .appendingPathComponent("../")
            .appendingPathComponent("../")
            .appendingPathComponent("Sources")
            .appendingPathComponent("Derived")
            .appendingPathComponent("GraphQL")

        let folderUrl =
            baseFolderUrl
            .appendingPathComponent(name.capitalized)

        try! ApolloFileManager.default.deleteDirectory(atPath: folderUrl.path)
        try! ApolloFileManager.default.createDirectoryIfNeeded(atPath: baseFolderUrl.path)
        try! ApolloFileManager.default.createDirectoryIfNeeded(atPath: folderUrl.path)

        let hGraphQLUrl =
            sourceRootURL?
            .appendingPathComponent("hGraphQL")
            .appendingPathComponent("GraphQL")
            .appendingPathComponent(name.capitalized)

        let hGraphQLSymlinkUrl = sourceUrl.appendingPathComponent("hGraphQL")

        let ishGraphQLFolder = folderUrl.absoluteString.contains("Projects/hGraphQL")

        var symlinks: [URL] = []

        if !ishGraphQLFolder {
            symlinks.append(hGraphQLSymlinkUrl)
            if let hGraphQLUrl {
                try? FileManager.default.createSymbolicLink(at: hGraphQLSymlinkUrl, withDestinationURL: hGraphQLUrl)
            }
        } else {
            sourceUrls.filter { url in
                !url.absoluteString.contains("hGraphQL")
            }
            .forEach { sourceUrl in
                let hGraphQLSymlinkUrl =
                    sourceUrl
                    .appendingPathComponent(name.capitalized)

                var projectName: String {
                    let pattern = "/Projects/([^/]+)/"
                    let input = sourceUrl.absoluteString

                    if let range = input.range(of: pattern, options: .regularExpression, range: nil, locale: nil) {
                        let projectNameWithSlash = String(input[range])
                        let projectName =
                            projectNameWithSlash
                            .replacingOccurrences(of: "/Projects/", with: "")
                            .replacingOccurrences(of: "/", with: "")
                        return projectName
                    }

                    fatalError("Couldn't find project name for \(sourceUrl)")
                }
                if let hGraphQLUrl {
                    let symlinkUrl = hGraphQLUrl.appendingPathComponent(projectName)
                    symlinks.append(symlinkUrl)

                    try? FileManager.default.createSymbolicLink(
                        at: symlinkUrl,
                        withDestinationURL: hGraphQLSymlinkUrl
                    )
                }
            }
        }

        let codegenOptions = ApolloCodegenConfiguration(
            schemaNamespace: "\(name.capitalized)GraphQL",
            input: ApolloCodegenConfiguration.FileInput(
                schemaPath: cliFolderURL.appendingPathComponent("introspection_response.json").path
            ),
            output: ApolloCodegenConfiguration.FileOutput(schemaTypes: .init(path: folderUrl.path, moduleType: .other))
        )

        Task {
            try! await ApolloCodegen.build(with: codegenOptions)
        }

        if !ishGraphQLFolder {
            var allGeneratedFiles = try! FileManager.default.contentsOfDirectory(
                at: folderUrl,
                includingPropertiesForKeys: nil,
                options: []
            )

            if let hGraphQLUrl {
                let allhGraphQLFiles = try! FileManager.default.contentsOfDirectory(
                    at: hGraphQLUrl,
                    includingPropertiesForKeys: nil,
                    options: []
                )

                allGeneratedFiles.filter { generatedFile in
                    let originalFileName = generatedFile.lastPathComponent.replacingOccurrences(
                        of: ".swift",
                        with: ""
                    )

                    return allhGraphQLFiles.first(where: { $0.lastPathComponent.contains(originalFileName) }) != nil
                }
                .forEach { url in
                    allGeneratedFiles.removeAll(where: { $0 == url })
                    try? FileManager.default.removeItem(at: url)
                }
            }

            allGeneratedFiles.forEach { file in
                let fileHandle = try! FileHandle(forWritingTo: file)
                fileHandle.seek(toFileOffset: 0)
                let fileData = try! String(contentsOf: file, encoding: .utf8).data(using: .utf8)!
                var data = "import hGraphQL\n".data(using: .utf8)!
                data.append(fileData)
                fileHandle.write(data)
                fileHandle.closeFile()
            }

            try? FileManager.default.removeItem(at: folderUrl.appendingPathComponent("Types.graphql.swift"))
        } else {
            let allGeneratedFiles = try! FileManager.default.contentsOfDirectory(
                at: folderUrl,
                includingPropertiesForKeys: nil,
                options: []
            )

            if let hGraphQLUrl {
                let allhGraphQLFiles = try! FileManager.default.contentsOfDirectory(
                    at: hGraphQLUrl,
                    includingPropertiesForKeys: nil,
                    options: []
                )

                allGeneratedFiles.filter { generatedFile in
                    let originalFileName = generatedFile.lastPathComponent.replacingOccurrences(
                        of: ".swift",
                        with: ""
                    )

                    return allhGraphQLFiles.first(where: { $0.lastPathComponent.contains(originalFileName) }) == nil
                }
                .filter { !$0.lastPathComponent.contains("Types.graphql.swift") }
                .forEach { url in try? FileManager.default.removeItem(at: url) }

            }

            allGeneratedFiles
                .filter { $0.lastPathComponent.contains("Types.graphql.swift") }
                .forEach { typesFileUrl in
                    let destination =
                        typesFileUrl
                        .deletingLastPathComponent()
                        .appendingPathComponent("\(name.capitalized)Types.graphql.swift")
                    try! FileManager.default.moveItem(at: typesFileUrl, to: destination)
                }
        }

        symlinks.forEach { symlink in
            try? FileManager.default.removeItem(at: symlink)
        }
    }
}
