import ApolloCodegenLib
import Foundation

let parentFolderOfScriptFile = FileFinder.findParentFolder()
let sourceRootURL = parentFolderOfScriptFile.deletingLastPathComponent().deletingLastPathComponent()
    .deletingLastPathComponent()

let cliFolderURL = FileManager.default.urls(for: .cachesDirectory, in: .allDomainsMask).first!
    .appendingPathComponent("Codegen").appendingPathComponent("ApolloCLI")

try FileManager.default.createDirectory(at: cliFolderURL, withIntermediateDirectories: true, attributes: nil)

let endpoint = URL(string: "https://graphql.dev.hedvigit.com/graphql")!

let options = ApolloSchemaOptions(endpointURL: endpoint, outputFolderURL: cliFolderURL)

try ApolloSchemaDownloader.run(with: cliFolderURL, options: options)

func getFolders(basePath: String = sourceRootURL.path, accessModifier: ApolloCodegenOptions.AccessModifier) -> [URL] {
    guard let dirs = try? FileManager.default.contentsOfDirectory(atPath: basePath) else { return [] }
    
    let ownDirs = dirs.filter { $0 == accessModifier.directory }.map { URL(string: "file://\(basePath)/\($0)") }.compactMap { $0 }
    
    let nestedDirs = dirs.compactMap { $0 }
        .map {
            val -> [URL] in
            getFolders(basePath: "\(basePath)/\(val)", accessModifier: accessModifier) }
        .flatMap { $0 }
        .filter { !$0.absoluteString.contains("Derived") }
    
    return [ownDirs, nestedDirs].flatMap { $0 }
}

func findAndAddGraphQLFolders(for folderURLS: [URL], accessModifier: ApolloCodegenOptions.AccessModifier) {
    folderURLS.forEach { sourceUrl in
        
        let folderUrl = sourceUrl.appendingPathComponent("../").appendingPathComponent("Sources")
            .appendingPathComponent("Derived").appendingPathComponent("GraphQL")
        
        try? FileManager.default.apollo.createFolderIfNeeded(at: folderUrl)
        
        let hGraphQLUrlBase = sourceRootURL.appendingPathComponent("hGraphQL")
        let hGraphQLUrl = hGraphQLUrlBase.appendingPathComponent("GraphQL")
        let hGraphQLSymlinkUrl = sourceUrl.appendingPathComponent("hGraphQL")
        
        let isGraphQLFolder = folderUrl.absoluteString.contains("Projects/hGraphQL")
        
        if !isGraphQLFolder {
            try? FileManager.default.createSymbolicLink(at: hGraphQLSymlinkUrl, withDestinationURL: hGraphQLUrl)
        }
        
        let codegenOptions = ApolloCodegenOptions(
            modifier: accessModifier,
            namespace: "GraphQL",
            outputFormat: .multipleFiles(inFolderAtURL: folderUrl),
            urlToSchemaFile: cliFolderURL.appendingPathComponent("schema.json")
        )
        
        let fromUrl =
            isGraphQLFolder ? sourceUrl.appendingPathComponent("../").appendingPathComponent("../") : sourceUrl
        
        try! ApolloCodegen.run(from: fromUrl, with: cliFolderURL, options: codegenOptions)
        
        if !isGraphQLFolder {
            var allGeneratedFiles = try! FileManager.default.contentsOfDirectory(
                at: folderUrl,
                includingPropertiesForKeys: nil,
                options: []
            )
            
            let allhGraphQLFiles = fetchFileURLs(for: hGraphQLUrl.deletingLastPathComponent())
            
            allGeneratedFiles.filter { generatedFile in
                let originalFileName = generatedFile.lastPathComponent.replacingOccurrences(
                    of: ".swift",
                    with: ""
                )
                
                return allhGraphQLFiles.first(where: { $0.lastPathComponent.contains(originalFileName) }) != nil
            }
            .forEach { url in allGeneratedFiles.removeAll(where: { $0 == url })
                try? FileManager.default.removeItem(at: url)
            }
            
            allGeneratedFiles.forEach { file in let fileHandle = try! FileHandle(forWritingTo: file)
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
            
            let allGraphQLFiles = fetchFileURLs(for: hGraphQLUrlBase)
            
            allGeneratedFiles.filter { generatedFile in
                let originalFileName = generatedFile.lastPathComponent.replacingOccurrences(
                    of: ".swift",
                    with: ""
                )
                
                return allGraphQLFiles.first(where: { $0.lastPathComponent.contains(originalFileName) }) == nil
            }
            .filter { !$0.lastPathComponent.contains("Types.graphql.swift") }
            .forEach {
                url in try? FileManager.default.removeItem(at: url)
            }
        }
        
        try? FileManager.default.removeItem(at: hGraphQLSymlinkUrl)
        
        // Mark: Hack to make internal models internal
        if accessModifier == .internal {
            
            let internalGraphQLFiles = try! FileManager.default.contentsOfDirectory(
                at: sourceUrl,
                includingPropertiesForKeys: nil,
                options: []
            )
            
            let allGeneratedFiles = try! FileManager.default.contentsOfDirectory(
                at: folderUrl,
                includingPropertiesForKeys: nil,
                options: []
            ).filter { generatedFile in
                let originalFileName = generatedFile.lastPathComponent.replacingOccurrences(
                    of: ".swift",
                    with: ""
                )
                
                return internalGraphQLFiles.first(where: { $0.lastPathComponent.contains(originalFileName) }) != nil
            }.forEach { url in
                var text = try? String(contentsOf: url, encoding: .utf8)
                
                text = text?.replacingOccurrences(of: "public", with: "internal", options: .literal, range: nil)
                
                try? text?.write(to: url, atomically: false, encoding: .utf8)
            }
        }
    }
}

func fetchFileURLs(for sourceUrl: URL) -> [URL] {
    let publicGraphQLFiles = try! FileManager.default.contentsOfDirectory(
        at: sourceUrl.appendingPathComponent(ApolloCodegenOptions.AccessModifier.public.directory),
        includingPropertiesForKeys: nil,
        options: []
    )
    
    let internalGraphQLFiles = try! FileManager.default.contentsOfDirectory(
        at: sourceUrl.appendingPathComponent(ApolloCodegenOptions.AccessModifier.internal.directory),
        includingPropertiesForKeys: nil,
        options: []
    )
    
    return publicGraphQLFiles + internalGraphQLFiles
}

findAndAddGraphQLFolders(for: getFolders(accessModifier: .public), accessModifier: .public)
findAndAddGraphQLFolders(for: getFolders(accessModifier: .internal), accessModifier: .internal)

extension ApolloCodegenOptions.AccessModifier {
    var directory: String {
        switch self {
        case .internal:
            return "InternalGraphQL"
        default:
            return "GraphQL"
        }
    }
}
