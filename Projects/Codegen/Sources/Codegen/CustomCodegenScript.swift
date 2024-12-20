import ApolloCodegenLib
import ArgumentParser
import Foundation

let sourceRootURL: URL? = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
    .deletingLastPathComponent().deletingLastPathComponent()

let cliFolderURL = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first!
    .appendingPathComponent("Codegen").appendingPathComponent("ApolloCLI")

let endpoint = (name: "octopus", url: URL(string: "https://apollo-router.dev.hedvigit.com/")!)

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

let sourceUrls = findAllGraphQLFolders()

@main
struct CustomCodegenScript: AsyncParsableCommand {
    func run() async throws {

        try FileManager.default.createDirectory(at: cliFolderURL, withIntermediateDirectories: true, attributes: nil)

        let downloadConfiguration = ApolloSchemaDownloadConfiguration(
            using: .introspection(endpointURL: endpoint.url),
            outputPath: cliFolderURL.path + "/schema.graphqls"
        )

        do {
            try await ApolloSchemaDownloader.fetch(configuration: downloadConfiguration)
            print("suceeded to download schema")
        } catch let error {
            print("Failed to download schema ", error)
        }

        await sourceUrls.forEachAsync { sourceUrl in
            await buildSchema(sourceUrl: sourceUrl)
        }
        sourceUrls.forEach { sourceUrl in
            cleanup(sourceUrl: sourceUrl)
        }

    }

    func buildSchema(sourceUrl: URL) async {
        let sourceUrl = sourceUrl.appendingPathComponent(endpoint.name.capitalized)

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
            .appendingPathComponent(endpoint.name.capitalized)

        try! ApolloFileManager.default.deleteDirectory(atPath: folderUrl.path)
        try! ApolloFileManager.default.createDirectoryIfNeeded(atPath: baseFolderUrl.path)
        try! ApolloFileManager.default.createDirectoryIfNeeded(atPath: folderUrl.path)

        let hGraphQLUrl =
            sourceRootURL?
            .appendingPathComponent("hGraphQL")
            .appendingPathComponent("GraphQL")
            .appendingPathComponent(endpoint.name.capitalized)

        let hGraphQLSymlinkUrl = sourceUrl.appendingPathComponent("hGraphQL")

        let ishGraphQLFolder = folderUrl.absoluteString.contains("Projects/hGraphQL")

        var symlinks: [URL] = []

        if !ishGraphQLFolder {
            symlinks.append(hGraphQLSymlinkUrl)
            if let hGraphQLUrl {
                try? FileManager.default.createSymbolicLink(
                    at: hGraphQLSymlinkUrl,
                    withDestinationURL: hGraphQLUrl
                )
            }
        } else {
            sourceUrls.filter { url in
                !url.absoluteString.contains("hGraphQL")
            }
            .forEach { sourceUrl in
                let hGraphQLSymlinkUrl =
                    sourceUrl
                    .appendingPathComponent(endpoint.name.capitalized)

                var projectName: String {
                    let pattern = "/Projects/([^/]+)/"
                    let input = sourceUrl.absoluteString

                    if let range = input.range(
                        of: pattern,
                        options: .regularExpression,
                        range: nil,
                        locale: nil
                    ) {
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

        let operationSearchPaths: [String] = {
            if ishGraphQLFolder {
                return sourceUrls.compactMap({ $0.appendingPathComponent(endpoint.name.capitalized) })
                    .filter({ ApolloFileManager.default.doesDirectoryExist(atPath: $0.path) })
                    .compactMap({ $0.appendingPathComponent("*.graphql") }).compactMap({ $0.path })
            } else {
                return [
                    sourceUrl.appendingPathComponent("*.graphql").path,
                    sourceUrl.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
                        .appendingPathComponent("hGraphQL/GraphQL/Octopus/*.graphql").path,
                ]
            }
        }()
        print("PATH IS \(operationSearchPaths)")

        let moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType = {
            return .embeddedInTarget(name: "\(endpoint.name.capitalized)GraphQL", accessModifier: .public)
        }()
        let codegenOptions = ApolloCodegenConfiguration(
            schemaNamespace: "\(endpoint.name.capitalized)GraphQL",
            input: ApolloCodegenConfiguration.FileInput(
                schemaPath: cliFolderURL.appendingPathComponent("schema.graphqls").path,
                operationSearchPaths: operationSearchPaths
            ),
            output: ApolloCodegenConfiguration.FileOutput(
                schemaTypes: .init(path: folderUrl.path, moduleType: moduleType)
            )
        )
        do {
            try await ApolloCodegen.build(with: codegenOptions)
            print("succeeded to build schema ")
        } catch let error {
            print("Failed to build schema ", error)
        }

        if !ishGraphQLFolder {
            var allGeneratedFiles: [URL] = []
            let urlsToCheck = [
                folderUrl.appendingPathComponent("Operations").appendingPathComponent("Mutations"),
                folderUrl.appendingPathComponent("Operations").appendingPathComponent("Queries"),
            ]
            for urlToCheck in urlsToCheck {
                if ApolloFileManager.default.doesDirectoryExist(
                    atPath: urlToCheck.path
                ) {
                    allGeneratedFiles.append(
                        contentsOf: try! FileManager.default.contentsOfDirectory(
                            at: urlToCheck,
                            includingPropertiesForKeys: nil,
                            options: []
                        )
                    )
                }
            }

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

                    return allhGraphQLFiles.first(where: { $0.lastPathComponent.contains(originalFileName) })
                        != nil
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

            try? FileManager.default.removeItem(at: folderUrl.appendingPathComponent("OctopusGraphQL.graphql.swift"))
            try? FileManager.default.removeItem(at: folderUrl.appendingPathComponent("Schema"))
        }
        symlinks.forEach { symlink in
            try? FileManager.default.removeItem(at: symlink)
        }
    }

    func cleanup(sourceUrl: URL) {
        guard ApolloFileManager.default.doesDirectoryExist(atPath: sourceUrl.path) else {
            return
        }
        let baseFolderUrl =
            sourceUrl
            .appendingPathComponent("../")
            .appendingPathComponent("Sources")
            .appendingPathComponent("Derived")
            .appendingPathComponent("GraphQL")

        let folderUrl =
            baseFolderUrl
            .appendingPathComponent(endpoint.name.capitalized)
        let ishGraphQLFolder = folderUrl.absoluteString.contains("Projects/hGraphQL")
        if !ishGraphQLFolder {
            let hGraphsQLFolder = sourceUrl.deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("hGraphQL/Sources/Derived/GraphQL/\(endpoint.name.capitalized)")
            let fragmentsFolder = folderUrl.appendingPathComponent("Fragments")
            try? FileManager.default.removeItem(at: fragmentsFolder)

            let mutationsFolder = folderUrl.appendingPathComponent("Operations").appendingPathComponent("Mutations")
            if ApolloFileManager.default.doesDirectoryExist(
                atPath: mutationsFolder.path
            ) {
                let objects = try! FileManager.default.contentsOfDirectory(
                    at: mutationsFolder,
                    includingPropertiesForKeys: nil,
                    options: []
                )
                let graphQLFolder = hGraphsQLFolder.appendingPathComponent("Operations")
                    .appendingPathComponent("Mutations")
                let graphQLFolderContent = try! FileManager.default
                    .contentsOfDirectory(
                        at: graphQLFolder,
                        includingPropertiesForKeys: nil,
                        options: []
                    )
                    .compactMap({ $0.lastPathComponent })
                for object in objects {
                    let objectName = object.lastPathComponent
                    if graphQLFolderContent.contains(objectName) {
                        try! FileManager.default.removeItem(at: graphQLFolder.appendingPathComponent(objectName))
                    }
                }
            }

            let queryFolder = folderUrl.appendingPathComponent("Operations").appendingPathComponent("Queries")

            if ApolloFileManager.default.doesDirectoryExist(
                atPath: queryFolder.path
            ) {
                let objects = try! FileManager.default.contentsOfDirectory(
                    at: queryFolder,
                    includingPropertiesForKeys: nil,
                    options: []
                )
                let graphQLFolder = hGraphsQLFolder.appendingPathComponent("Operations")
                    .appendingPathComponent("Queries")
                let graphQLFolderContent = try! FileManager.default
                    .contentsOfDirectory(
                        at: graphQLFolder,
                        includingPropertiesForKeys: nil,
                        options: []
                    )
                    .compactMap({ $0.lastPathComponent })
                for object in objects {
                    let objectName = object.lastPathComponent
                    if graphQLFolderContent.contains(objectName) {
                        try! FileManager.default.removeItem(at: graphQLFolder.appendingPathComponent(objectName))
                    }
                }
            }
        }
    }
}

extension Sequence {
    func forEachAsync(
        _ operation: (Element) async -> Void
    ) async {
        for element in self {
            await operation(element)
        }
    }

    func forEachAsync(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}
