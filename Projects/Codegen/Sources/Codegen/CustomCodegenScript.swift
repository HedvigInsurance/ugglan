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
    let nestedDirs = dirs.compactMap {
        URL(string: basePath + "/" + $0)?
            .appendingPathComponent("Sources")
            .appendingPathComponent("Derived")
            .appendingPathComponent("GraphQL")
    }
    return nestedDirs
}

@main
struct CustomCodegenScript: AsyncParsableCommand {
    func run() async throws {
        try await downloadSchema()
        await cleanDerivedData()
        let url = sourceRootURL!
            .appendingPathComponent("hGraphQL")
            .appendingPathComponent("GraphQL")
            .appendingPathComponent(endpoint.name.capitalized)
        await buildSchema(sourceUrl: url)
    }

    func downloadSchema() async throws {
        try FileManager.default.createDirectory(at: cliFolderURL, withIntermediateDirectories: true, attributes: nil)

        let downloadConfiguration = ApolloSchemaDownloadConfiguration(
            using: .introspection(endpointURL: endpoint.url),
            outputPath: cliFolderURL.path + "/schema.graphqls"
        )

        do {
            try await ApolloSchemaDownloader.fetch(configuration: downloadConfiguration)
            print("suceeded to download schema")
        } catch {
            print("Failed to download schema ", error)
        }
    }

    func cleanDerivedData() async {
        for sourceUrl in findAllGraphQLFolders() {
            let url = sourceUrl.path
            try? await ApolloFileManager.default.deleteDirectory(atPath: url)
        }
    }

    func buildSchema(sourceUrl: URL) async {
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

        try! await ApolloFileManager.default.deleteDirectory(atPath: folderUrl.path)
        try! await ApolloFileManager.default.createDirectoryIfNeeded(atPath: baseFolderUrl.path)
        try! await ApolloFileManager.default.createDirectoryIfNeeded(atPath: folderUrl.path)

        var operationSearchPaths = [String]()
        let content = try! FileManager.default.contentsOfDirectory(at: sourceUrl, includingPropertiesForKeys: nil)
        operationSearchPaths.append(sourceUrl.appendingPathComponent("*.graphql").path)
        for item in content {
            if await ApolloFileManager.default.doesDirectoryExist(atPath: item.path) {
                operationSearchPaths.append(item.appendingPathComponent("*.graphql").path)
            }
        }
        let moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType = .embeddedInTarget(
            name: "\(endpoint.name.capitalized)GraphQL",
            accessModifier: .public
        )
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
        } catch {
            print("Failed to build schema ", error)
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
