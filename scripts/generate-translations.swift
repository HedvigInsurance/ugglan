#!/usr/bin/env swift

import Foundation

let placeholderRegex = try NSRegularExpression(pattern: "(\\{[a-zA-Z0-9]+\\})")
let placeholderKeyRegex = try NSRegularExpression(pattern: "([a-zA-Z0-9]+)")

let colorWhite = "\u{001B}[0;0m"
let colorRed = "\u{001B}[0;31m"
let colorYellow = "\u{001B}[0;33m"
let colorGreen = "\u{001B}[0;32m"

if CommandLine.arguments.index(of: "--help") != nil {
    print("""
        \(colorWhite)Hedvig Translations Codegen

        Arguments:
            \(colorWhite)--projects: The projects you want to fetch translations for (for example: "[App, IOS]") \u{001B}[0;31mREQUIRED
            \(colorWhite)--destination: Full path of desired destination for generated Swift file (including ".swift", for example "translations/translations.swift") \(colorRed)REQUIRED
            \(colorWhite)--swiftformat-path: The path to the Swiftformat CLI \(colorYellow)OPTIONAL
            \(colorWhite)--curl-path: The path to Curl \(colorYellow)OPTIONAL
    """)
    exit(1)
}

if CommandLine.arguments.index(of: "--projects") == nil {
    print("\(colorRed)You need to pass in argument '--projects'")
    exit(1)
}

if CommandLine.arguments.index(of: "--destination") == nil {
    print("\(colorRed)You need to pass in argument '--destination'")
    exit(1)
}

let swiftFormatCLIArgumentIndex = CommandLine.arguments.index(of: "--swiftformat-path")
let swiftFormatCLIPath = swiftFormatCLIArgumentIndex != nil ? CommandLine.arguments[swiftFormatCLIArgumentIndex! + 1] : "/usr/local/bin/swiftformat"

let curlCLIArgumentIndex = CommandLine.arguments.index(of: "--curl-path")
let curlCLIPath = curlCLIArgumentIndex != nil ? CommandLine.arguments[curlCLIArgumentIndex! + 1] : "/usr/bin/curl"

if !FileManager.default.fileExists(atPath: swiftFormatCLIPath) {
    print("\(colorRed)Swiftformat not installed at '\(swiftFormatCLIPath)'")
    exit(1)
}

if !FileManager.default.fileExists(atPath: curlCLIPath) {
    print("\(colorRed)Curl not installed at '\(curlCLIPath)'")
    exit(1)
}

let projects = CommandLine.arguments[CommandLine.arguments.index(of: "--projects")! + 1]
let destination = CommandLine.arguments[CommandLine.arguments.index(of: "--destination")! + 1]

let curlTask = Process()

curlTask.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
curlTask.arguments = [
    "-s",
    "https://api-euwest.graphcms.com/v1/cjmawd9hw036a01cuzmjhplka/master",
    "-H",
    "Accept-Encoding: gzip",
    "-H",
    "Content-Type: application/json",
    "-H",
    "Accept: */*",
    "-H",
    "Connection: keep-alive",
    "--data-binary",
    """
    {"query":"query AppTranslationsMeta { languages { code translations(where: { project_in: \(projects) }) { text key { value } language { code } } } keys(where: { translations_every: { project_in: \(projects) } }) { value description } }","variables":null,"operationName":"AppTranslationsMeta"}
    """,
    "--compressed",
]

let outPipe = Pipe()
curlTask.standardOutput = outPipe

curlTask.launch()

let jsonData = outPipe.fileHandleForReading.readDataToEndOfFile()

curlTask.waitUntilExit()

struct GraphCMSTranslation: Decodable {
    let text: String
    let key: GraphCMSKey
}

struct GraphCMSLanguage: Decodable {
    let code: String
    let translations: [GraphCMSTranslation]
}

struct GraphCMSKey: Decodable {
    let value: String
    let description: String?
}

struct GraphCMSData: Decodable {
    let languages: [GraphCMSLanguage]
    let keys: [GraphCMSKey]
}

struct GraphCMSRoot: Decodable {
    let data: GraphCMSData
}

let graphCMSRoot = try? JSONDecoder().decode(GraphCMSRoot.self, from: jsonData)

guard let graphCMSRoot = graphCMSRoot else {
    let plainJsonRepsonse = String(data: jsonData, encoding: .utf8)
    print("\(colorRed)Could not fetch translations from GraphCMS correctly, returned response was: \n\n\(colorWhite)\(plainJsonRepsonse ?? "nil")")
    exit(1)
}

func findReplacements(_ text: String) -> [String] {
    let range = NSRange(location: 0, length: text.utf16.count)

    let results = placeholderRegex.matches(in: text, options: [], range: range)

    return Array(Set(results.compactMap {
        String(text[Range($0.range, in: text)!])
    })).sorted { $0 < $1 }
}

func removeCurlyBraces(_ text: String, replaceOpeningWith: String = "", replaceClosingWith: String = "") -> String {
    return text.replacingOccurrences(of: "{", with: replaceOpeningWith).replacingOccurrences(of: "}", with: replaceClosingWith)
}

/// removes curly braces from replacements
func cleanReplacements(_ replacements: [String]) -> [String] {
    return replacements
        .map { removeCurlyBraces($0) }
}

func indent(_ string: String, _ numberOfIndents: Int) -> String {
    var resultingString = "\(string)"

    for _ in 0 ... numberOfIndents {
        resultingString = " \(resultingString)"
    }

    return resultingString
}

func languageEnumCases() -> String {
    let cases = graphCMSRoot.data.languages.map { language -> String in
        let enumCase = indent("case \(language.code)", 6)

        if language.code == graphCMSRoot.data.languages.last!.code {
            return enumCase
        }

        return "\(enumCase)\n"
    }

    return cases.compactMap { $0 }.joined()
}

func keysEnumCases() -> String {
    let keys = graphCMSRoot.data.keys.map { key -> String in
        print("\(colorGreen)Generating: \(key.value)\n")
        print("\(colorWhite)\(key.description ?? "")\n\n")

        let description = key.description != nil ? "\(indent("/// \(key.description ?? "")", 6))\n" : ""

        let replacementArguments = graphCMSRoot.data.languages.map { language -> [GraphCMSTranslation] in
            return language.translations.filter { $0.key.value == key.value }
        }.flatMap { $0.map { findReplacements($0.text) } }.flatMap { $0 }

        if replacementArguments.count != 0 {
            let argumentNames = cleanReplacements(replacementArguments)
            let argumentNamesSyntax = Array(Set(argumentNames)).sorted { $0 < $1 }.map { "\($0): String" }.joined(separator: ", ")

            return "\(description)\(indent("case \(key.value)(\(argumentNamesSyntax))", 6))"
        }

        return "\(description)\(indent("case \(key.value)", 6))"
    }

    return keys.joined(separator: "\n")
}

func languageStructs() -> String {
    func getStaticForFunc(_ content: String) -> String {
        let switchStatementEnd = indent("}", 10)
        let switchStatement = indent("switch key {\n\(content)\n\(switchStatementEnd)", 10)
        return indent("""
        static func `for`(key: Localization.Key) -> String {\n\(switchStatement)\n\(indent("}", 8))
        """, 8)
    }

    func getSwitchCases(_ language: GraphCMSLanguage) -> String {
        let switchCases = language.translations.filter { translation in
            let key = graphCMSRoot.data.keys.first { key in key.value == translation.key.value }

            if key == nil {
                print("\(colorYellow)WARNING \(colorWhite)hanging translation that is referencing key: \(colorYellow)\(translation.key.value)\(colorWhite), it had the value: \(colorYellow)\"\(translation.text)\"\(colorWhite)\n")
                return false
            }
            
            return true
        }.map { translation in
            let replacements = cleanReplacements(findReplacements(translation.text))
            var translationsRepoReplacements = replacements
                .map { name in "\"\(name)\": \(name)" }.joined(separator: ", ")

            if translationsRepoReplacements.count == 0 {
                translationsRepoReplacements = ":"
            }

            let translationsRepoReturnStatement = indent("return text", 12)
            let translationsRepoClosingBracket = indent("}", 10)
            let translationsRepo = indent("""
                if let text = TranslationsRepo.findWithReplacements(key, replacements: [\(translationsRepoReplacements)]) {
                \(translationsRepoReturnStatement)
                \(translationsRepoClosingBracket)
                
            """, 10)

            let fallbackValue = indent("""
                return \"\"\"
                \(indent(removeCurlyBraces(translation.text, replaceOpeningWith: "\\(", replaceClosingWith: ")"), 10))
                \(indent("\"\"\"", 10))
            """, 10)

            let body = "\(translationsRepo)\n\(fallbackValue)"

            if replacements.count != 0 {
                let arguments = replacements.map { "\($0)" }.joined(separator: ", ")
                return indent("case let .\(translation.key.value)(\(arguments)):\n\(body)\n", 12)
            }

            return indent("case .\(translation.key.value):\n\(body)\n", 12)
        }.joined(separator: "").dropLast(1)

        let defaultStatement = indent("default: return String(key)", 12)

        return "\(String(switchCases))\n\(defaultStatement)"
    }

    let structs = graphCMSRoot.data.languages.map {
        indent("""
        struct \($0.code) {
        \(getStaticForFunc(getSwitchCases($0)))\n
        """, 6)
    }.map { "\($0)\(indent("}\n", 6))" }.joined()

    return String(structs.dropLast(1))
}

let output = """
// Generated automagically, don't edit yourself

import Foundation

// swiftlint:disable identifier_name type_body_length type_name line_length nesting file_length

public struct Localization {
    enum Language {
\(languageEnumCases())
    }

    enum Key {
\(keysEnumCases())
    }

    struct Translations {
\(languageStructs())
    }
}
"""

let file: ()? = try? output.write(toFile: "\(destination)", atomically: true, encoding: .utf8)

if file == nil {
    print("\(colorRed)Couldn't write file to destination '\(destination)'")
    exit(1)
}

let swiftFormatTask = Process()
swiftFormatTask.executableURL = URL(fileURLWithPath: "/usr/local/bin/swiftformat")
swiftFormatTask.arguments = [destination, "--quiet"]

swiftFormatTask.launch()

swiftFormatTask.waitUntilExit()

print("\(colorGreen)File generation completed!")
