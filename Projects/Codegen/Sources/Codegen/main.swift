import ApolloCodegenLib
import Foundation

let parentFolderOfScriptFile = FileFinder.findParentFolder()
let sourceRootURL = parentFolderOfScriptFile
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()

let cliFolderURL = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first!
    .appendingPathComponent("Codegen")
    .appendingPathComponent("ApolloCLI")

try? FileManager.default.removeItem(at: cliFolderURL)

try FileManager.default.createDirectory(
    at: cliFolderURL,
    withIntermediateDirectories: true,
    attributes: nil
)

let endpoint = URL(string: "https://graphql.dev.hedvigit.com/graphql")!

let options = ApolloSchemaOptions(
    endpointURL: endpoint,
    outputFolderURL: cliFolderURL
)

try ApolloSchemaDownloader.run(
    with: cliFolderURL,
    options: options
)

func findAllGraphQLFolders(basePath: String = sourceRootURL.path) -> [URL] {
    guard let dirs = try? FileManager.default.contentsOfDirectory(atPath: basePath) else {
        return []
    }
            
    let ownDirs = dirs.filter({ $0 == "GraphQL"}).map { URL(string: "file://\(basePath)/\($0)") }.compactMap { $0 }
    
    let nestedDirs = dirs.compactMap { $0 }.map { val -> [URL] in
        findAllGraphQLFolders(basePath: "\(basePath)/\(val)")
    }.flatMap { $0 }
        
    return [ownDirs, nestedDirs].flatMap { $0 }
}

let sourceUrls = findAllGraphQLFolders()

sourceUrls.forEach { sourceUrl in
    let codegenOptions = ApolloCodegenOptions(
        outputFormat: .singleFile(atFileURL: sourceUrl
            .appendingPathComponent("../")
            .appendingPathComponent("Sources")
            .appendingPathComponent("Derived")
            .appendingPathComponent("API.swift")
        ),
        urlToSchemaFile: cliFolderURL.appendingPathComponent("schema.json")
    )

    try! ApolloCodegen.run(
        from: sourceUrl,
        with: cliFolderURL,
        options: codegenOptions
    )
}
