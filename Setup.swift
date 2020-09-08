import Foundation
import ProjectDescription

func isCI() -> Bool {
    if case let .boolean(isCI) = Environment.CI {
        return isCI
    } else {
        return false
    }
}

let setup = Setup([
    .homebrew(packages: ["swiftlint", "carthage", "swiftformat"]),
    .custom(name: "Carthage", meet: ["./scripts/carthage.sh"], isMet: ["scripts/carthage-verify.sh"]),
    !isCI() ? .custom(name: "Install Git Hooks", meet: ["./scripts/githooks.sh"], isMet: ["exit 0"]) : nil,
    .custom(name: "Translations", meet: ["./scripts/translations.sh"], isMet: ["exit 1"]),
    .custom(name: "Swiftgen", meet: ["./scripts/swiftgen.sh"], isMet: ["exit 1"]),
    .custom(name: "Apollo Codegen", meet: ["./scripts/codegen.sh"], isMet: ["exit 1"])
].compactMap { $0 })
