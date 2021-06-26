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

func findAllGraphQLFolders(basePath: String = sourceRootURL.path) -> [URL] {
	guard let dirs = try? FileManager.default.contentsOfDirectory(atPath: basePath) else { return [] }

	let ownDirs = dirs.filter { $0 == "GraphQL" }.map { URL(string: "file://\(basePath)/\($0)") }.compactMap { $0 }

	let nestedDirs = dirs.compactMap { $0 }
		.map { val -> [URL] in findAllGraphQLFolders(basePath: "\(basePath)/\(val)") }.flatMap { $0 }
		.filter { !$0.absoluteString.contains("Derived") }

	return [ownDirs, nestedDirs].flatMap { $0 }
}

let sourceUrls = findAllGraphQLFolders()

sourceUrls.forEach { sourceUrl in

	let folderUrl = sourceUrl.appendingPathComponent("../").appendingPathComponent("Sources")
		.appendingPathComponent("Derived").appendingPathComponent("GraphQL")

	try? FileManager.default.apollo.createFolderIfNeeded(at: folderUrl)

	let hGraphQLUrl = sourceRootURL.appendingPathComponent("hGraphQL").appendingPathComponent("GraphQL")
	let hGraphQLSymlinkUrl = sourceUrl.appendingPathComponent("hGraphQL")

	let ishGraphQLFolder = folderUrl.absoluteString.contains("Projects/hGraphQL")

	if !ishGraphQLFolder {
		try? FileManager.default.createSymbolicLink(at: hGraphQLSymlinkUrl, withDestinationURL: hGraphQLUrl)
	}

	let codegenOptions = ApolloCodegenOptions(
		namespace: "GraphQL",
		outputFormat: .multipleFiles(inFolderAtURL: folderUrl),
		urlToSchemaFile: cliFolderURL.appendingPathComponent("schema.json")
	)

	let fromUrl =
		ishGraphQLFolder ? sourceUrl.appendingPathComponent("../").appendingPathComponent("../") : sourceUrl

	try! ApolloCodegen.run(from: fromUrl, with: cliFolderURL, options: codegenOptions)

	if !ishGraphQLFolder {
		var allGeneratedFiles = try! FileManager.default.contentsOfDirectory(
			at: folderUrl,
			includingPropertiesForKeys: nil,
			options: []
		)

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

	try? FileManager.default.removeItem(at: hGraphQLSymlinkUrl)
}
