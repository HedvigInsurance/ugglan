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

let endpoint = URL(string: "https://graphql.dev.hedvigit.com/graphql")!

let options = ApolloSchemaOptions(
    endpointURL: endpoint,
    outputFolderURL: cliFolderURL
)

do {
    try ApolloSchemaDownloader.run(with: cliFolderURL,
                                   options: options)
} catch {
    exit(1)
}

let sourceUrls = [
    sourceRootURL
    .appendingPathComponent("App")
    .appendingPathComponent("GraphQL"),
    sourceRootURL
    .appendingPathComponent("Embark")
    .appendingPathComponent("GraphQL")
]

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

    do {
        try ApolloCodegen.run(from: sourceUrl,
                              with: cliFolderURL,
                              options: codegenOptions)
    } catch {
        exit(1)
    }
}
